USE inventory_management;

CREATE OR REPLACE VIEW customer_tier AS

SELECT
    customer_id,
    customer_name,
    total_spent,
    CASE
        WHEN total_spent >= 2000 THEN 'Gold'
        WHEN total_spent >= 500 THEN 'Silver'
        ELSE 'Bronze'
    END AS tier

FROM customer_spending;
