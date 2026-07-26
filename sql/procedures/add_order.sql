USE inventory_management;

DELIMITER $$

CREATE PROCEDURE add_order_item(

    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT

)
BEGIN

    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;

    SELECT
        price,
        stock_quantity
    INTO
        v_price,
        v_stock
    FROM products
    WHERE product_id = p_product_id;

    IF v_stock < p_quantity THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock available';

    ELSE

        INSERT INTO order_details(

            order_id,
            product_id,
            quantity,
            unit_price,
            discount

        )

        VALUES(

            p_order_id,
            p_product_id,
            p_quantity,
            v_price,
            0

        );

    END IF;

END$$

DELIMITER ;