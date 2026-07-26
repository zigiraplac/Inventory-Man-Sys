SELECT

    customer_name,

    total_spent,

    CASE

        WHEN total_spent >= 2000
            THEN 'Gold'

        WHEN total_spent >= 500
            THEN 'Silver'

        ELSE 'Bronze'

    END AS customer_tier

FROM customer_spending

ORDER BY total_spent DESC;