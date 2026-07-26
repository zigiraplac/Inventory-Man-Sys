USE inventory_management;

SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    p.product_name,
    od.quantity,
    od.unit_price
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_details od
    ON o.order_id = od.order_id
JOIN products p
    ON od.product_id = p.product_id;