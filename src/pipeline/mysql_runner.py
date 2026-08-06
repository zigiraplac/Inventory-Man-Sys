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
import tempfile
from pathlib import Path

logger = logging.getLogger("pipeline")

# Every file under sql/ hardcodes this name (`USE inventory_management;`,
# and database.sql's `CREATE DATABASE IF NOT EXISTS inventory_management;`)
# so that scripts/run_all.sql keeps working standalone, with no Python and
# no per-environment config involved. When config.db_name differs (e.g.
# config/test.yaml's inventory_management_test), run_sql_file sources a
# rewritten copy instead of editing anything on disk.
HARDCODED_DB_NAME = "inventory_management"


class SqlFileError(RuntimeError):
    """Raised when a .sql file fails to execute."""


def run_sql_file(sql_path: Path, config) -> None:
    if not sql_path.exists():
        raise SqlFileError(f"{sql_path} does not exist")

    source_path = sql_path
    temp_path: Path | None = None

    if config.db_name != HARDCODED_DB_NAME:
        rewritten = sql_path.read_text(encoding="utf-8").replace(
            HARDCODED_DB_NAME, config.db_name
        )
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".sql", delete=False, encoding="utf-8"
        ) as tmp:
            tmp.write(rewritten)
            temp_path = Path(tmp.name)
        source_path = temp_path

    command = [
        config.mysql_client,
        "-h", config.db_host,
        "-P", str(config.db_port),
        "-u", config.db_user,
        "-e", f"SOURCE {source_path.as_posix()};",
    ]

    # Password goes through the environment, never argv or a log line —
    # MYSQL_PWD is the mysql client's documented mechanism for this.
    env = os.environ.copy()
    if config.db_password:
        env["MYSQL_PWD"] = config.db_password

    try:
        result = subprocess.run(command, env=env, capture_output=True, text=True)
    finally:
        if temp_path is not None:
            temp_path.unlink(missing_ok=True)

    if result.returncode != 0:
        raise SqlFileError(
            f"{sql_path} failed (exit {result.returncode}): {result.stderr.strip()}"
        )

    if result.stderr.strip():
        logger.debug("%s stderr: %s", sql_path, result.stderr.strip())
