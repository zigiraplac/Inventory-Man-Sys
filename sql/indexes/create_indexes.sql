USE inventory_management;

-- Products
CREATE INDEX idx_products_category
ON products(category);

-- Orders
CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_orders_date
ON orders(order_date);

-- Order Details
CREATE INDEX idx_order_details_order
ON order_details(order_id);

CREATE INDEX idx_order_details_product
ON order_details(product_id);

-- Inventory Logs
CREATE INDEX idx_inventory_product
ON inventory_logs(product_id);

CREATE INDEX idx_inventory_date
ON inventory_logs(created_at);