# Data dictionary

Derived from `sql/schema/*.sql`. This is documentation only — the schema
files themselves remain the source of truth.

## customers

| Column          | Type          | Notes                                   |
|-----------------|---------------|------------------------------------------|
| customer_id     | INT, PK       | auto-increment                          |
| first_name      | VARCHAR(50)   |                                          |
| last_name       | VARCHAR(50)   |                                          |
| email           | VARCHAR(100)  | unique                                  |
| phone           | VARCHAR(20)   | nullable                                |
| customer_tier   | VARCHAR(10)   | 'Bronze' / 'Silver' / 'Gold'; written only by `trg_update_customer_tier`, see `sql/schema/alter_customers_add_tiers.sql` |
| created_at      | TIMESTAMP     | defaults to now                         |

## products

| Column          | Type            | Notes                                 |
|-----------------|-----------------|-----------------------------------------|
| product_id      | INT, PK         | auto-increment                        |
| product_name    | VARCHAR(100)    |                                        |
| category        | VARCHAR(50)     |                                        |
| price           | DECIMAL(10,2)   | >= 0                                   |
| stock_quantity  | INT             | >= 0; decremented by `trg_reduce_stock` |
| reorder_level   | INT             | default 10; threshold used by `vw_low_stock` and `evt_auto_replenish` |
| created_at      | TIMESTAMP       |                                        |
| updated_at      | TIMESTAMP       | on-update auto-refresh                |

## orders

| Column        | Type          | Notes                                       |
|---------------|---------------|-----------------------------------------------|
| order_id      | INT, PK       | auto-increment                              |
| customer_id   | INT, FK       | → customers.customer_id, RESTRICT on delete |
| order_date    | TIMESTAMP     | defaults to now                             |
| total_amount  | DECIMAL(10,2) | recalculated by `trg_update_order_total`    |
| status        | VARCHAR(20)   | default 'PENDING'                           |

## order_details

| Column           | Type          | Notes                                        |
|------------------|---------------|-------------------------------------------------|
| order_detail_id  | INT, PK       | auto-increment                                |
| order_id         | INT, FK       | → orders.order_id, RESTRICT on delete          |
| product_id       | INT, FK       | → products.product_id, RESTRICT on delete      |
| quantity         | INT           | > 0                                            |
| unit_price       | DECIMAL(10,2) | snapshotted from products.price at insert time |
| discount         | DECIMAL(5,2)  | bulk-quantity discount %, set by `add_order_item` |

## inventory_logs

| Column             | Type          | Notes                                          |
|--------------------|---------------|---------------------------------------------------|
| log_id             | INT, PK       | auto-increment                                   |
| product_id         | INT, FK       | → products.product_id, RESTRICT on delete         |
| previous_quantity  | INT           |                                                    |
| new_quantity       | INT           |                                                    |
| quantity_change    | INT           | new - previous                                   |
| reason             | VARCHAR(50)   | 'ORDER_PLACED', 'REPLENISHMENT', or 'STOCK UPDATE' — set via the `@inventory_reason` session variable, read by `trg_inventory_log` |
| created_at         | TIMESTAMP     |                                                    |

## Views

- `vw_order_summary` — one row per order with customer name/tier, item count, total units.
- `vw_low_stock` — products at or below `reorder_level`.
- `vw_customer_spending` — per-customer order count and lifetime spend (excludes cancelled orders).
- `vw_customer_tier` — reads `customer_tier` from `vw_customer_spending`; does not recompute thresholds (see `docs/architecture.md`).
