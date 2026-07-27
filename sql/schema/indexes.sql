USE inventory_management;

-- Foreign keys are indexed automatically by InnoDB in MySQL/MariaDB,
-- but the columns below support additional query patterns used by the
-- views and reports and are not covered by an FK index alone.

CREATE INDEX idx_orders_customer_status ON orders (customer_id, status);
CREATE INDEX idx_orders_order_date ON orders (order_date);
CREATE INDEX idx_products_stock_reorder ON products (stock_quantity, reorder_level);
CREATE INDEX idx_inventory_logs_product_created ON inventory_logs (product_id, created_at);
