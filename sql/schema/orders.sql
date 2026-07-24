USE inventory_management;


CREATE TABLE orders (

    order_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL,

    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    total_amount DECIMAL(10,2) DEFAULT 0,

    status VARCHAR(20) DEFAULT 'PENDING',

    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);