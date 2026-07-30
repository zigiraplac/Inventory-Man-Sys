USE inventory_management;

DROP VIEW IF EXISTS vw_customer_tier;

-- Tier is computed once, by trg_update_customer_tier, at the moment a
-- customer's spend changes. This view just reads that stored value —
-- it does not recompute the thresholds.
CREATE VIEW vw_customer_tier AS

SELECT
    customer_id,
    customer_name,
    total_spent,
    customer_tier AS tier

FROM vw_customer_spending;
