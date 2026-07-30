USE inventory_management;

-- Makes run_all.sql idempotent: rebuild from scratch, twice in a row,
-- with zero manual cleanup. Dropped in FK-safe order (children before
-- parents) so InnoDB never rejects a drop for a still-referenced table.

DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS inventory_logs;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
