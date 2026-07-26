SELECT

    p.category,

    SUM(
        od.quantity *
        od.unit_price *
        (1 - od.discount / 100)
    ) AS revenue

FROM order_details od

JOIN products p

ON od.product_id = p.product_id

GROUP BY p.category

ORDER BY revenue DESC;