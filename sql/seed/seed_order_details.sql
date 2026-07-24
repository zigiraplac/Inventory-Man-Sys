USE inventory_management;

INSERT INTO order_details
(order_id, product_id, quantity, unit_price, discount)

VALUES

-- Order 1
(1, 1, 1, 1299.99, 0),
(1, 4, 2, 89.99, 0),

-- Order 2
(2, 2, 1, 999.99, 0),
(2, 5, 1, 120.00, 0),

-- Order 3
(3, 3, 2, 299.99, 0),
(3, 8, 1, 150.00, 0);