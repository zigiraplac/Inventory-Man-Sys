USE inventory_management;


CREATE TABLE order_details (

    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,


    order_id INT NOT NULL,


    product_id INT NOT NULL,


    quantity INT NOT NULL
        CHECK(quantity > 0),


    unit_price DECIMAL(10,2) NOT NULL,


    discount DECIMAL(5,2) DEFAULT 0,


    CONSTRAINT fk_detail_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id),


    CONSTRAINT fk_detail_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)

);