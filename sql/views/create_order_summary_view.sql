USE inventory_management;

CREATE OR REPLACE VIEW order_summary AS

SELECT

    o.order_id,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    o.order_date,

    o.status,

    COUNT(od.order_detail_id) AS number_of_products,

    SUM(od.quantity) AS total_items,

    o.total_amount

FROM orders o

JOIN customers c
ON o.customer_id = c.customer_id

LEFT JOIN order_details od
ON o.order_id = od.order_id

GROUP BY

    o.order_id,
    customer_name,
    o.order_date,
    o.status,
    o.total_amount;