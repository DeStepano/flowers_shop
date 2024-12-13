set search_path = flower_shop, public;

-- Статистика продаж. Ниже представлены названия цветов, их цена, общее количество проданных единиц, количество заказов, в которых присутствовал товар, а также среднее количество товара на заказ.
CREATE OR REPLACE VIEW flower_shop.product_sales_statistics AS
SELECT
    p.name_flower AS product_name,
    p.price,                        
    COALESCE(SUM(pxo.amount), 0) AS total_quantity_sold,  
    COUNT(DISTINCT pxo.order_id) AS number_of_orders,
    CASE 
        WHEN COUNT(DISTINCT pxo.order_id) > 0 THEN 
            ROUND(SUM(pxo.amount)::NUMERIC / COUNT(DISTINCT pxo.order_id), 1)
        ELSE 0 
    END AS average_quantity_per_order 
FROM
    flower_shop.Product p
LEFT JOIN
    flower_shop.Product_X_Order pxo ON p.product_id = pxo.product_id
LEFT JOIN
    flower_shop."Order" o ON pxo.order_id = o.order_id AND o.status = 'DELIVERED'
GROUP BY
    p.product_id, p.name_flower, p.price
ORDER BY
    total_quantity_sold DESC;


--  Статистика Поставок (отслеживание активности и надежности поставиков). Включает в себя информацию о поставщиках, включая общее количество поставок, общее количество поставленных товаров и дату последней поставки.
CREATE OR REPLACE VIEW flower_shop.supplier_supply_statistics AS
SELECT
    s.name AS supplier_name,    
    s.city AS supplier_city,    
    COUNT(sp.supply_id) AS total_supplies,
    COALESCE(SUM(ps.amount), 0) AS total_products_supplied, 
    MAX(sp.date) AS last_supply_date    
FROM
    flower_shop.Supplier s
LEFT JOIN
    flower_shop.Supply sp ON s.supplier_id = sp.supplier_id
LEFT JOIN
    flower_shop.Product_X_Supply ps ON sp.supply_id = ps.supply_id
GROUP BY
    s.supplier_id, s.name, s.city
ORDER BY
    total_supplies DESC;

-- Статистика Заказов Клиентов: общее количество заказов(только delivered), общая сумма, потраченная клиентом и среднюю стоимость заказа.
CREATE OR REPLACE VIEW flower_shop.client_order_statistics AS
SELECT
    c.first_name,          
    c.last_name,      
    c.login,                              
    COUNT(o.order_id) AS total_orders,   
    COALESCE(SUM(o.price), 0) AS total_amount_spent, 
    CASE 
        WHEN COUNT(o.order_id) > 0 THEN 
            SUM(o.price)::NUMERIC / COUNT(o.order_id)
        ELSE 0 
    END AS average_order_price          
FROM
    flower_shop.Client c
LEFT JOIN
    flower_shop."Order" o ON c.client_id = o.client_id AND o.status = 'DELIVERED'
GROUP BY
    c.client_id, c.first_name, c.last_name, c.login
ORDER BY
    total_amount_spent DESC;        