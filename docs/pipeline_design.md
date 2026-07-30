# Pipeline design

## Phases

Defined in `src/pipeline/pipeline.py::PHASES`, in this order:

| Phase        | What it does                                                        |
|--------------|----------------------------------------------------------------------|
| `database`   | `CREATE DATABASE IF NOT EXISTS` + `USE`                             |
| `drop_all`   | Drops all 5 tables in FK-safe order, for a clean rebuild             |
| `schema`     | Creates `customers`, `products`, `orders`, `order_details`, `inventory_logs`; adds `customer_tier`; creates indexes |
| `triggers`   | Stock reduction, order total recalculation, inventory logging, customer tier recalculation |
| `seed`       | Seed data for customers/products/orders/order_details                |
| `procedures` | `create_order`, `add_order_item`, `place_order`, `place_bulk_order`, `replenish_stock` |
| `views`      | `vw_order_summary`, `vw_low_stock`, `vw_customer_spending`, `vw_customer_tier` |
| `events`     | `evt_auto_replenish` (disabled by default)                           |

Each phase is a list of `.sql` file paths relative to `sql/`. `run_pipeline()`
runs every file in every phase in order, logging start/OK/duration per file
and per phase, and raises `PipelineError` on the first failure — naming
exactly which file failed.

## Adding a phase or a file to an existing phase

1. Add or edit the corresponding `.sql` file under `sql/`.
2. Add its path to the relevant tuple in `PHASES` (and to `scripts/run_all.sql`,
   which is still the standalone, Python-free way to build the database).
3. Add its path to `tests/test_pipeline.py::test_all_phase_files_exist_on_disk`
   coverage — no action needed there specifically, since that test already
   iterates `PHASES` generically; it will pick up the new entry automatically.

## Configuration

`src/pipeline/config.py::load_config(env)` loads `config/<env>.yaml`
(`dev`, `test`, `prod`, or `docker`), then lets environment variables of
the same name (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_NAME`, `MYSQL_CLIENT`)
override any field — `DB_PASSWORD` *only* ever comes from the environment
(via `.env`, never from a yaml file) since it's a secret.

## Logging

`src/pipeline/logging_setup.py::setup_logging()` configures the
`"pipeline"` logger once at startup with two handlers: a console handler
at the configured `log_level`, and a `RotatingFileHandler` writing full
`DEBUG`-level detail to `logs/pipeline.log` (rotated at 1MB, 3 backups)
so a failed run can be inspected after the fact.

## Known limitation

`MYSQL_PWD` (used to pass the DB password to the `mysql` CLI subprocess
without putting it in argv) is readable via `/proc/<pid>/environ` on Linux
for the duration of that process. This is the standard, documented way the
`mysql` client accepts a non-interactive password and is an acceptable
tradeoff for a local dev/lab environment; a production deployment should
use a `--defaults-extra-file` with restricted permissions or a secrets
manager instead.
