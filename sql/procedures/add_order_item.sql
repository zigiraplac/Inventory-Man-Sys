USE inventory_management;

DROP PROCEDURE IF EXISTS add_order_item;

DELIMITER $$

CREATE PROCEDURE add_order_item(

    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT

)
BEGIN

    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_discount DECIMAL(5,2);

    SELECT
        price,
        stock_quantity
    INTO
        v_price,
        v_stock
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_price IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist';
    END IF;

    IF v_stock < p_quantity THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock available';

    ELSE

        -- Bulk-quantity discount tiers (tune to your business rules):
        --   1-4 units  -> 0%
        --   5-9 units  -> 5%
        --   10+ units  -> 10%
        SET v_discount = CASE
            WHEN p_quantity >= 10 THEN 10.00
            WHEN p_quantity >= 5  THEN 5.00
            ELSE 0.00
        END;

        SET @inventory_reason = 'ORDER_PLACED';

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
            v_discount

        );

        SET @inventory_reason = NULL;

    END IF;

END$$

DELIMITER ;
