USE inventory_management;

DROP PROCEDURE IF EXISTS replenish_stock;

DELIMITER $$

CREATE PROCEDURE replenish_stock(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Replenishment quantity must be greater than zero';
    END IF;

    SET @inventory_reason = 'REPLENISHMENT';

    UPDATE products
    SET stock_quantity = stock_quantity + p_quantity
    WHERE product_id = p_product_id;

    SET @inventory_reason = NULL;

END $$

DELIMITER ;