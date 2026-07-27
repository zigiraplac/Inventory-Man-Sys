USE inventory_management;

DROP TRIGGER IF EXISTS trg_update_customer_tier;

DELIMITER $$

-- Fires whenever an order's total_amount or status changes (this includes
-- the moment trg_update_order_total recalculates total_amount after items
-- are added). Recomputes the customer's lifetime spend and updates their
-- tier accordingly. Cancelled orders don't count toward spend.
--
-- Thresholds (tune to your business):
--   Bronze : spend <  $500
--   Silver : spend >= $500  and < $2000
--   Gold   : spend >= $2000

CREATE TRIGGER trg_update_customer_tier
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN

    DECLARE v_total_spend DECIMAL(12,2);

    SELECT IFNULL(SUM(total_amount), 0)
    INTO v_total_spend
    FROM orders
    WHERE customer_id = NEW.customer_id
      AND status <> 'CANCELLED';

    UPDATE customers
    SET customer_tier = CASE
        WHEN v_total_spend >= 2000 THEN 'Gold'
        WHEN v_total_spend >= 500  THEN 'Silver'
        ELSE 'Bronze'
    END
    WHERE customer_id = NEW.customer_id;

END $$

DELIMITER ;
