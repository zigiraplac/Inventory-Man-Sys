-- ============================================================
-- Master build script — run this with:
--   mysql -u root < 00_run_all.sql
-- from the project root. It rebuilds the whole database from
-- scratch in the correct dependency order.
-- ============================================================

SOURCE sql/schema/database.sql;
SOURCE sql/schema/00_drop_all.sql;
SOURCE sql/schema/customers.sql;
SOURCE sql/schema/products.sql;
SOURCE sql/schema/orders.sql;
SOURCE sql/schema/order_details.sql;
SOURCE sql/schema/inventory_logs.sql;
SOURCE sql/schema/alter_customers_add_tiers.sql;
SOURCE sql/schema/indexes.sql;

SOURCE sql/triggers/trg_reduce_stock.sql;
SOURCE sql/triggers/trg_update_order_total.sql;
SOURCE sql/triggers/trg_inventory_log.sql;
SOURCE sql/triggers/trg_update_customer_tier.sql;

SOURCE sql/seed/seed_customers.sql;
SOURCE sql/seed/seed_products.sql;
SOURCE sql/seed/seed_orders.sql;
SOURCE sql/seed/seed_order_details.sql;

SOURCE sql/procedures/create_order.sql;
SOURCE sql/procedures/add_order_item.sql;
SOURCE sql/procedures/place_order.sql;
SOURCE sql/procedures/place_bulk_order.sql;
SOURCE sql/procedures/replenish_stock.sql;

SOURCE sql/views/vw_order_summary.sql;
SOURCE sql/views/vw_low_stocks.sql;
SOURCE sql/views/vw_customer_spending.sql;
SOURCE sql/views/vw_customer_tier.sql;

-- Optional — leaves auto-replenishment DISABLED. Enable manually if wanted:
SOURCE sql/events/evt_auto_replenish.sql;

SELECT 'Build complete.' AS status;
