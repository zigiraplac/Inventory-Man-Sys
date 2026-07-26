USE inventory_management;

CREATE OR REPLACE VIEW customer_spending AS

SELECT

    c.customer_id,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    COUNT(o.order_id) AS total_orders,

    COALESCE(SUM(o.total_amount),0) AS total_spent

FROM customers c

LEFT JOIN orders o

ON c.customer_id = o.customer_id

GROUP BY

    c.customer_id,
    customer_name;