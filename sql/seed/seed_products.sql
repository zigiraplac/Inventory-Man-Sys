USE inventory_management;

INSERT INTO products
(product_name, category, price, stock_quantity, reorder_level)

VALUES
('Dell XPS 13 Laptop', 'Electronics', 1299.99, 25, 10),
('Apple iPhone 15', 'Electronics', 999.99, 40, 15),
('Samsung 27-inch Monitor', 'Electronics', 299.99, 18, 8),
('Logitech MX Master 3 Mouse', 'Accessories', 89.99, 60, 20),
('Mechanical Keyboard', 'Accessories', 120.00, 35, 10),
('Office Chair', 'Furniture', 250.00, 12, 5),
('Standing Desk', 'Furniture', 450.00, 10, 5),
('USB-C Docking Station', 'Accessories', 150.00, 28, 10),
('External SSD 1TB', 'Storage', 140.00, 45, 15),
('Webcam HD', 'Accessories', 75.00, 32, 10);