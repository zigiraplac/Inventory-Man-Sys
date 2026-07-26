USE inventory_management;

CREATE OR REPLACE VIEW low_stock_products AS

SELECT

    product_id,

    product_name,

    category,

    stock_quantity,

    reorder_level,

    reorder_level - stock_quantity AS shortage

FROM products

WHERE stock_quantity <= reorder_level;