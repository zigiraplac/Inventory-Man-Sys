USE inventory_management;

DROP PROCEDURE IF EXISTS create_order;

DELIMITER $$

CREATE PROCEDURE create_order (
    IN p_customer_id INT
)
BEGIN

    DECLARE v_customer_exists INT;

    SELECT COUNT(*) INTO v_customer_exists
    FROM customers
    WHERE customer_id = p_customer_id;

    IF v_customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;

    INSERT INTO orders (
        customer_id,
        order_date,
        total_amount,
        status
    )
    VALUES (
        p_customer_id,
        NOW(),
        0,
        'PENDING'
    );

END $$

DELIMITER ;