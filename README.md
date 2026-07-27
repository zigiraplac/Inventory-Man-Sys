# Inventory and Order Management System

This project implements a database-backed inventory and order management system for an e-commerce workflow. It supports product tracking, order placement, stock updates, inventory logging, customer spending insights, and low-stock reporting.

## Project Structure

- `sql/schema/` — table creation scripts
- `sql/procedures/` — stored procedures for order placement, bulk order handling, and replenishment
- `sql/triggers/` — inventory and order automation triggers
- `sql/views/` — business views for order summaries, customer spending, customer tiers, and low-stock products
- `sql/seed/` — seed data for products, customers, orders, and order details
- `sql/indexes/` — indexes for performance
- `scripts/run_all.sql` — bootstrap script to build the database and load initial data
- `sql/reports/` — sample reporting queries

## Implementation Approach

### Phase 1: Schema Design

1. `products` table captures product inventory, price, stock, and reorder threshold.
2. `customers` table stores customer identity and contact details.
3. `orders` table records order metadata and total amount.
4. `order_details` captures the line items for each order.
5. `inventory_logs` tracks every stock change for auditing.

### Phase 2: Order Placement & Inventory Management

- `create_order.sql` inserts a pending order.
- `add_order.sql` validates stock and inserts order line items.
- `place_order.sql` creates an order and adds a single item.
- `place_bulk_order.sql` supports multi-item orders using JSON payloads.
- `replenish.sql` updates stock and logs replenishment.
- Triggers automatically:
  - decrement stock after order item insertion
  - update order totals after order item insertion
  - log inventory changes after stock updates

### Phase 3: Monitoring & Reporting

- `order_summary` view provides order-level metrics by customer.
- `customer_spending` view aggregates customer spending.
- `customer_tier` view classifies customers into Bronze/Silver/Gold.
- `low_stock_products` view lists products that need reorder.

### Phase 4: Automation

- Inventory changes are logged automatically with `trg_inventory_log`.
- Stock decrements and order totals are automated with `trg_reduce_stock` and `trg_update_order_total`.
- Bulk order support simplifies multi-item order processing.

### Phase 5: Optimization

- Indexes on common join and filter columns improve query performance.
- Views encapsulate business logic for reuse and reporting.

## How to Run

1. Open your MySQL client.
2. Execute:

```sql
SOURCE c:/Users/USER/Documents/AmaliTech/Projects/inventory-order-management/scripts/run_all.sql;
```

3. Verify tables and views:

```sql
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

## Example Usage

Place a single-item order:

```sql
CALL place_order(1, 2, 3);
```

Place a bulk order:

```sql
CALL place_bulk_order(2, '[{"product_id": 1, "quantity": 1}, {"product_id": 4, "quantity": 2}]');
```

Replenish stock:

```sql
CALL replenish_stock(3, 20);
```

Query order summaries:

```sql
SELECT * FROM order_summary;
```

Query low-stock products:

```sql
SELECT * FROM low_stock_products;
```

Query customer tiers:

```sql
SELECT * FROM customer_tier;
```

## Best Practices

- Keep all DDL, DML, and business logic version-controlled.
- Use environment-specific deployment scripts for production.
- Keep triggers focused on auditing and enforcement, not business decisions.
- Persist inventory logs for traceability and audit compliance.
- Use views to expose clean reporting datasets to analytics teams.
