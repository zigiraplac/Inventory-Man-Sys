USE inventory_management;

DELIMITER $$

CREATE TRIGGER trg_inventory_log
AFTER UPDATE ON products
FOR EACH ROW
BEGIN

    IF OLD.stock_quantity <> NEW.stock_quantity THEN

        INSERT INTO inventory_logs(

            product_id,
            previous_quantity,
            new_quantity,
            quantity_change,
            reason

        )

        VALUES(

            NEW.product_id,
            OLD.stock_quantity,
            NEW.stock_quantity,
            NEW.stock_quantity - OLD.stock_quantity,
            'STOCK UPDATE'

        );

    END IF;

END $$

DELIMITER ;