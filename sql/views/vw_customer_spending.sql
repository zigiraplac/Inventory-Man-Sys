USE inventory_management;

DROP VIEW IF EXISTS vw_customer_spending;

CREATE VIEW vw_customer_spending AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_tier,
    COUNT(o.order_id) AS total_orders,
    IFNULL(SUM(CASE WHEN o.status <> 'CANCELLED' THEN o.total_amount ELSE 0 END), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_tier
ORDER BY total_spent DESC;
