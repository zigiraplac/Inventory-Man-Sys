USE inventory_management;

DROP VIEW IF EXISTS vw_order_summary;

CREATE VIEW vw_order_summary AS
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_tier,
    o.order_date,
    o.status,
    o.total_amount,
    COUNT(od.order_detail_id) AS item_count,
    SUM(od.quantity) AS total_units
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN order_details od ON od.order_id = o.order_id
GROUP BY
    o.order_id,
    c.first_name,
    c.last_name,
    c.customer_tier,
    o.order_date,
    o.status,
    o.total_amount;
