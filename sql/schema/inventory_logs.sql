USE inventory_management;


CREATE TABLE inventory_logs (

    log_id INT AUTO_INCREMENT PRIMARY KEY,


    product_id INT NOT NULL,


    previous_quantity INT NOT NULL,


    new_quantity INT NOT NULL,


    quantity_change INT NOT NULL,


    reason VARCHAR(50) NOT NULL,


    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_inventory_product

        FOREIGN KEY(product_id)

        REFERENCES products(product_id)

);