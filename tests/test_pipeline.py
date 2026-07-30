"""Unit tests for the pipeline orchestration layer.

These test the orchestration logic only (phase list, config loading,
--only/--from filtering) — no live database is required, so this runs
the same on a laptop with no MySQL installed as it does in CI.
"""
import pytest

from pipeline import config as config_module
from pipeline.pipeline import PHASE_NAMES, PHASES, SQL_DIR, _select_phases


def test_all_phase_files_exist_on_disk():
    for phase_name, relative_paths in PHASES:
        for relative_path in relative_paths:
            sql_path = SQL_DIR / relative_path
            assert sql_path.exists(), f"{phase_name}: missing {sql_path}"


def test_phase_names_are_unique():
    assert len(PHASE_NAMES) == len(set(PHASE_NAMES))


def test_select_phases_default_returns_everything():
    assert _select_phases(only=None, from_phase=None) == PHASES


def test_select_phases_only():
    selected = _select_phases(only="seed", from_phase=None)
    assert [name for name, _ in selected] == ["seed"]


def test_select_phases_from():
    selected = _select_phases(only=None, from_phase="procedures")
    assert [name for name, _ in selected] == ["procedures", "views", "events"]


def test_select_phases_unknown_only_raises():
    with pytest.raises(ValueError):
        _select_phases(only="not_a_phase", from_phase=None)


def test_select_phases_unknown_from_raises():
    with pytest.raises(ValueError):
        _select_phases(only=None, from_phase="not_a_phase")


def test_load_config_dev(monkeypatch):
    monkeypatch.delenv("DB_HOST", raising=False)
    monkeypatch.delenv("DB_PASSWORD", raising=False)
    config = config_module.load_config("dev")
    assert config.env == "dev"
    assert config.db_name == "inventory_management"


def test_load_config_env_var_overrides_yaml(monkeypatch):
    monkeypatch.setenv("DB_HOST", "override-host")
    config = config_module.load_config("dev")
    assert config.db_host == "override-host"


def test_load_config_unknown_env_raises():
    with pytest.raises(FileNotFoundError):
        config_module.load_config("does_not_exist")
