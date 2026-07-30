#!/usr/bin/env python
"""CLI entrypoint: orchestrates the SQL lab build via src/pipeline.

Usage:
    python scripts/run_pipeline.py --env dev
    python scripts/run_pipeline.py --env dev --only reports
    python scripts/run_pipeline.py --env dev --from procedures
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "src"))

from pipeline.config import load_config
from pipeline.logging_setup import setup_logging
from pipeline.pipeline import PHASE_NAMES, PipelineError, run_pipeline


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the inventory/order SQL lab pipeline.")
    parser.add_argument(
        "--env", default=None,
        help="Environment name (dev/test/prod/docker). Defaults to $APP_ENV or 'dev'.",
    )
    parser.add_argument(
        "--only", default=None, choices=PHASE_NAMES,
        help="Run only this phase.",
    )
    parser.add_argument(
        "--from", dest="from_phase", default=None, choices=PHASE_NAMES,
        help="Run from this phase through to the end.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    config = load_config(args.env)
    setup_logging(config.log_level)

    try:
        run_pipeline(config, only=args.only, from_phase=args.from_phase)
    except PipelineError:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
