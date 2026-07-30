USE inventory_management;

DROP PROCEDURE IF EXISTS create_order;

DELIMITER $$

CREATE PROCEDURE create_order (
    IN p_customer_id INT
)
BEGIN

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