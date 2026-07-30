"""Orchestrates the SQL lab build as an ordered sequence of phases.

The phase order mirrors scripts/run_all.sql exactly. Unlike sourcing
that file as one monolithic block, each file here is run and logged
individually, so a failure is attributed to the exact file that caused
it instead of a single opaque error partway through a long script.
"""
from __future__ import annotations

import logging
import time
from pathlib import Path

from .mysql_runner import SqlFileError, run_sql_file

logger = logging.getLogger("pipeline")

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
SQL_DIR = PROJECT_ROOT / "sql"

PHASES = [
    ("database", ["schema/database.sql"]),
    ("drop_all", ["schema/00_drop_all.sql"]),
    ("schema", [
        "schema/customers.sql",
        "schema/products.sql",
        "schema/orders.sql",
        "schema/order_details.sql",
        "schema/inventory_logs.sql",
        "schema/alter_customers_add_tiers.sql",
        "schema/indexes.sql",
    ]),
    ("triggers", [
        "triggers/trg_reduce_stock.sql",
        "triggers/trg_update_order_total.sql",
        "triggers/trg_inventory_log.sql",
        "triggers/trg_update_customer_tier.sql",
    ]),
    ("seed", [
        "seed/seed_customers.sql",
        "seed/seed_products.sql",
        "seed/seed_orders.sql",
        "seed/seed_order_details.sql",
    ]),
    ("procedures", [
        "procedures/create_order.sql",
        "procedures/add_order_item.sql",
        "procedures/place_order.sql",
        "procedures/place_bulk_order.sql",
        "procedures/replenish_stock.sql",
    ]),
    ("views", [
        "views/vw_order_summary.sql",
        "views/vw_low_stocks.sql",
        "views/vw_customer_spending.sql",
        "views/vw_customer_tier.sql",
    ]),
    ("events", ["events/evt_auto_replenish.sql"]),
]

PHASE_NAMES = [name for name, _ in PHASES]


class PipelineError(RuntimeError):
    """Raised when the pipeline aborts due to a failed phase."""


def _select_phases(only: str | None, from_phase: str | None):
    if only:
        if only not in PHASE_NAMES:
            raise ValueError(f"Unknown phase '{only}'. Known phases: {PHASE_NAMES}")
        return [(name, files) for name, files in PHASES if name == only]

    if from_phase:
        if from_phase not in PHASE_NAMES:
            raise ValueError(f"Unknown phase '{from_phase}'. Known phases: {PHASE_NAMES}")
        start = PHASE_NAMES.index(from_phase)
        return PHASES[start:]

    return PHASES


def run_pipeline(config, only: str | None = None, from_phase: str | None = None) -> None:
    phases = _select_phases(only, from_phase)

    logger.info("Starting pipeline run (env=%s, phases=%s)", config.env, [n for n, _ in phases])

    for phase_name, relative_paths in phases:
        logger.info("Phase '%s' starting", phase_name)
        phase_start = time.monotonic()

        for relative_path in relative_paths:
            sql_path = SQL_DIR / relative_path
            file_start = time.monotonic()
            try:
                run_sql_file(sql_path, config)
            except SqlFileError as exc:
                logger.error("Phase '%s' failed on %s: %s", phase_name, relative_path, exc)
                raise PipelineError(str(exc)) from exc
            logger.info("  %s OK (%.2fs)", relative_path, time.monotonic() - file_start)

        logger.info("Phase '%s' complete (%.2fs)", phase_name, time.monotonic() - phase_start)

    logger.info("Pipeline run complete.")
