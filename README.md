# Inventory and Order Management System

This repository contains the SQL implementation of an inventory and order management database for an e-commerce workflow.

Diagrams: [ERD](docs/erd.md) for the data model, [architecture](docs/architecture.md) for how the code is organized.

## Quick Start

### 1. Clone the repository

```powershell
git clone <repository-url> inventory-order-management
cd inventory-order-management
```

### 2. Install MySQL client or server

Use your preferred installer or package manager. The project assumes a local MySQL installation with the `mysql` client available.

On Windows with the installed MySQL binary, use:

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --version
```

If the command works, you are ready to run the project.

### 3. Initialize the database

Run the bootstrap script from the project root:

```powershell
Get-Content scripts\run_all.sql | & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p
```

Enter your MySQL root password when prompted.

### 4. Confirm the database exists

Then connect and verify:

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p inventory_management
```

Inside MySQL:

```sql
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

## What this repository contains

- `sql/schema/` — database schema scripts
- `sql/procedures/` — stored procedures for orders and replenishment
- `sql/triggers/` — automation for stock updates, totals, and tiers
- `sql/views/` — reporting views for orders, customers, and low-stock items
- `sql/seed/` — seed data for initial products, customers, orders, and order items
- `sql/indexes/` — performance indexes
- `sql/events/` — optional event automation scripts
- `scripts/run_all.sql` — single script to create schema, seed data, and deploy logic (Python-free, works standalone)
- `src/pipeline/`, `scripts/run_pipeline.py` — optional Python orchestration layer over the same SQL lab (see below and `docs/architecture.md`)
- `config/`, `docs/`, `tests/test_pipeline.py` — environment configs, docs, and unit tests for the Python layer

## Python pipeline (optional)

`scripts/run_all.sql` still works standalone with no Python involved. The
Python layer is an optional orchestrator on top of it — same phases, but
with structured logging, per-environment config, and the ability to
re-run a single phase.

```powershell
pip install -r requirements.txt
Copy-Item .env.example .env   # then edit .env with your real DB_PASSWORD
python scripts/run_pipeline.py --env dev
```

Useful flags:

```powershell
python scripts/run_pipeline.py --env dev --only views     # run just one phase
python scripts/run_pipeline.py --env dev --from procedures # run from a phase onward
```

Run the tests:

```powershell
python -m pytest
```

`tests/test_pipeline.py` covers orchestration logic only, no DB required.
`tests/test_procedures.py` exercises real procedures/triggers against the
disposable `inventory_management_test` database (config/test.yaml) — it
builds that database itself and never touches dev data; it's skipped
automatically if MySQL isn't reachable.

Or run everything in Docker (MySQL + pipeline containers):

```powershell
docker compose up --build
```

See `docs/architecture.md` for how this layer relates to the SQL lab,
and `docs/pipeline_design.md` for the phase list and how to extend it.

## Common workflows

Rebuilding the database is always the same command as Quick Start step 3
above — `run_all.sql` is idempotent, so re-running it drops and recreates
everything from scratch.

Connect and query:

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p inventory_management
```

```sql
SELECT * FROM orders LIMIT 20;
SELECT * FROM vw_order_summary LIMIT 20;
SELECT * FROM vw_customer_tier;
SELECT * FROM vw_low_stock;
```

Column-level constraints and what triggers what are documented in
`docs/data_dictionary.md`.

## Notes for collaborators

- If you change any schema or stored procedure files, update `scripts/run_all.sql` if needed.
- Keep view definitions and trigger logic version-controlled.
- This repo is designed for local development and testing of the inventory/order database pipeline.
