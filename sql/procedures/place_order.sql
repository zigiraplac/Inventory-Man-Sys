USE inventory_management;

DELIMITER $$

CREATE PROCEDURE place_order(

    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT

)
BEGIN

    DECLARE v_order_id INT;

    START TRANSACTION;

        CALL create_order(p_customer_id);

        SET v_order_id = LAST_INSERT_ID();

        CALL add_order_item(

            v_order_id,
            p_product_id,
            p_quantity

        );

    COMMIT;

END$$

DELIMITER ;