"""Loads pipeline configuration for a given environment.

Precedence: environment variables (including those loaded from .env)
override the matching field in config/<env>.yaml. This keeps secrets
(DB_PASSWORD) out of version control while letting the yaml files hold
everything else as committed, reviewable defaults.
"""
from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

import yaml
from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
CONFIG_DIR = PROJECT_ROOT / "config"


@dataclass
class Config:
    env: str
    db_host: str
    db_port: int
    db_user: str
    db_name: str
    db_password: str
    mysql_client: str
    log_level: str


def load_config(env: str | None = None) -> Config:
    env = env or os.getenv("APP_ENV", "dev")

    load_dotenv(PROJECT_ROOT / ".env", override=False)

    config_path = CONFIG_DIR / f"{env}.yaml"
    if not config_path.exists():
        raise FileNotFoundError(f"No config file for environment '{env}': {config_path}")

    with config_path.open("r", encoding="utf-8") as f:
        raw = yaml.safe_load(f) or {}

    return Config(
        env=env,
        db_host=os.getenv("DB_HOST", raw["db_host"]),
        db_port=int(os.getenv("DB_PORT", raw.get("db_port", 3306))),
        db_user=os.getenv("DB_USER", raw["db_user"]),
        db_name=os.getenv("DB_NAME", raw["db_name"]),
        db_password=os.getenv("DB_PASSWORD", ""),
        mysql_client=os.getenv("MYSQL_CLIENT", raw.get("mysql_client", "mysql")),
        log_level=raw.get("log_level", "INFO"),
    )
