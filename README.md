# Inventory and Order Management System

This repository contains the SQL implementation of an inventory and order management database for an e-commerce workflow.

## Quick Start

### 1. Clone the repository

```powershell
cd C:\Users\USER\Documents\AmaliTech\Projects
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
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p < scripts/run_all.sql
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
- `scripts/run_all.sql` — single script to create schema, seed data, and deploy logic

## Common user workflows

### Run the full project

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p < scripts/run_all.sql
```

### Connect directly to the project database

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p inventory_management
```

### Check current orders

```sql
SELECT * FROM orders LIMIT 20;
```

### View order summary

```sql
SELECT * FROM vw_order_summary LIMIT 20;
```

### View customer tiers

```sql
SELECT * FROM vw_customer_tier;
```

### View low-stock products

```sql
SELECT * FROM vw_low_stock;
```

## Helpful commands

### Run only schema and seed files

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p < scripts/run_all.sql
```

### Rebuild from scratch

If you want to rebuild the database and start clean:

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root -p < scripts/run_all.sql
```

### Use a specific database inside MySQL

```sql
USE inventory_management;
SHOW TABLES;
```

## Notes for collaborators

- If you change any schema or stored procedure files, update `scripts/run_all.sql` if needed.
- Keep view definitions and trigger logic version-controlled.
- This repo is designed for local development and testing of the inventory/order database pipeline.
