USE inventory_management;

DROP VIEW IF EXISTS vw_low_stock;

CREATE VIEW vw_low_stock AS
SELECT
    product_id,
    product_name,
    category,
    stock_quantity,
    reorder_level,
    (reorder_level - stock_quantity) AS units_below_reorder
FROM products
WHERE stock_quantity <= reorder_level
ORDER BY units_below_reorder DESC;
