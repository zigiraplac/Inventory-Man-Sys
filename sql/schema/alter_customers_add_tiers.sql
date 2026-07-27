USE inventory_management;

ALTER TABLE customers
    ADD COLUMN customer_tier VARCHAR(10) NOT NULL DEFAULT 'Bronze'
        AFTER phone;
