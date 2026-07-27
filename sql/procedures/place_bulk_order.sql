USE inventory_management;

DROP PROCEDURE IF EXISTS place_bulk_order;

DELIMITER $$

CREATE PROCEDURE place_bulk_order(
    IN p_customer_id INT,
    IN p_items JSON
)
BEGIN

    -- All DECLAREs must come first in MySQL/MariaDB procedure bodies --
    -- this was the bug: the cursor and handler were declared after
    -- START TRANSACTION / CALL, which is invalid syntax.

    DECLARE v_order_id INT;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE item_cursor CURSOR FOR
        SELECT product_id, quantity
        FROM JSON_TABLE(
            p_items,
            '$[*]' COLUMNS(
                product_id INT PATH '$.product_id',
                quantity INT PATH '$.quantity'
            )
        ) AS jt;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    CALL create_order(p_customer_id);
    SET v_order_id = LAST_INSERT_ID();

    OPEN item_cursor;

    read_loop: LOOP
        FETCH item_cursor INTO v_product_id, v_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL add_order_item(v_order_id, v_product_id, v_quantity);
    END LOOP;

    CLOSE item_cursor;
    COMMIT;

END $$

DELIMITER ;
