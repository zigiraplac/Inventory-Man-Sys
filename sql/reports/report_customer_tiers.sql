SELECT

    customer_name,

    total_spent,

    customer_tier AS tier

FROM vw_customer_spending

ORDER BY total_spent DESC;