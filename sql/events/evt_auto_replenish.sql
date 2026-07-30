USE inventory_management;

-- Optional automation: periodically top up any product at/below its
-- reorder_level back up to 3x that level. Left DISABLED by default —
-- enable it only if you actually want restocking to happen without a
-- human approving each replenishment (e.g. a purchasing manager).
--
-- To enable:   ALTER EVENT evt_auto_replenish ENABLE;
-- To disable:  ALTER EVENT evt_auto_replenish DISABLE;
-- Event scheduler must also be on:  SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS evt_auto_replenish;

DELIMITER $$

CREATE EVENT evt_auto_replenish
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DISABLE
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_stock INT;
    DECLARE v_reorder INT;

    DECLARE low_stock_cursor CURSOR FOR
        SELECT product_id, stock_quantity, reorder_level
        FROM products
        WHERE stock_quantity <= reorder_level;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN low_stock_cursor;

    replenish_loop: LOOP
        FETCH low_stock_cursor INTO v_product_id, v_stock, v_reorder;
        IF done THEN
            LEAVE replenish_loop;
        END IF;
        CALL replenish_stock(v_product_id, (v_reorder * 3) - v_stock);
    END LOOP;

    CLOSE low_stock_cursor;
END $$

DELIMITER ;
