"""Executes a single .sql file via the mysql CLI.

Shelling out to the same client scripts/run_all.sql already relies on
(rather than a Python DB driver) means DELIMITER $$ blocks in triggers
and procedures keep working — a raw driver has no notion of DELIMITER,
that's a mysql-client-only meta-command.
"""
from __future__ import annotations

import logging
import os
import subprocess
from pathlib import Path

logger = logging.getLogger("pipeline")


class SqlFileError(RuntimeError):
    """Raised when a .sql file fails to execute."""


def run_sql_file(sql_path: Path, config) -> None:
    if not sql_path.exists():
        raise SqlFileError(f"{sql_path} does not exist")

    command = [
        config.mysql_client,
        "-h", config.db_host,
        "-P", str(config.db_port),
        "-u", config.db_user,
        "-e", f"SOURCE {sql_path.as_posix()};",
    ]

    # Password goes through the environment, never argv or a log line —
    # MYSQL_PWD is the mysql client's documented mechanism for this.
    env = os.environ.copy()
    if config.db_password:
        env["MYSQL_PWD"] = config.db_password

    result = subprocess.run(command, env=env, capture_output=True, text=True)

    if result.returncode != 0:
        raise SqlFileError(
            f"{sql_path} failed (exit {result.returncode}): {result.stderr.strip()}"
        )

    if result.stderr.strip():
        logger.debug("%s stderr: %s", sql_path, result.stderr.strip())
