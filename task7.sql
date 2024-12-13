DROP SCHEMA IF EXISTS flower_shop_views CASCADE;

CREATE SCHEMA flower_shop_views;

SET search_path = flower_shop, flower_shop_views, public;


-- Supplier
CREATE OR REPLACE VIEW flower_shop_views.suppliers AS
SELECT
    name, LEFT(contacts, 4) || '******' || RIGHT(contacts, 4) AS masked_contacts,
    city
FROM flower_shop.supplier;

-- Supply
CREATE OR REPLACE VIEW flower_shop_views.supplies AS
SELECT
    s.date, sup.name AS supplier_name
FROM flower_shop.Supply s
JOIN flower_shop.Supplier sup ON s.supplier_id = sup.supplier_id;

-- Product
CREATE OR REPLACE VIEW flower_shop_views.products AS
SELECT
    name_flower,
    description,
    price,
    number_of_remaining
FROM flower_shop.Product;

-- Product_X_Supply (tech)
CREATE OR REPLACE VIEW flower_shop_views.product_x_supply AS
SELECT
    s.date AS supply_date,
    sup.name AS supplier_name,
    p.name_flower,
    pxs.amount
FROM flower_shop.Product_X_Supply pxs
JOIN flower_shop.Supply s ON pxs.supply_id = s.supply_id
JOIN flower_shop.Supplier sup ON s.supplier_id = sup.supplier_id
JOIN flower_shop.Product p ON pxs.product_id = p.product_id;

-- Client
CREATE OR REPLACE VIEW flower_shop_views.clients AS
SELECT
    LEFT(login, 2) || '****' AS masked_login,
    LEFT(first_name, 1) || '****' AS masked_first_name,
    LEFT(last_name, 1) || '****' AS masked_last_name
FROM flower_shop.client;

-- "Order"
CREATE OR REPLACE VIEW flower_shop_views.orders AS
SELECT
    LEFT(c.login, 2) || '****' AS masked_login,
    o.date,
    o.status,
    o.price
FROM flower_shop."Order" o
JOIN flower_shop.Client c ON o.client_id = c.client_id;

-- Product_X_Order
CREATE OR REPLACE VIEW flower_shop_views.product_x_order AS
SELECT
    o.date AS order_date,
    LEFT(c.login, 2) || '****' AS masked_login,
    p.name_flower,
    pxo.amount
FROM flower_shop.Product_X_Order pxo
JOIN flower_shop."Order" o ON pxo.order_id = o.order_id
JOIN flower_shop.Client c ON o.client_id = c.client_id
JOIN flower_shop.Product p ON pxo.product_id = p.product_id;

-- Department
CREATE OR REPLACE VIEW flower_shop_views.departments AS
SELECT
    name
FROM flower_shop.Department;

-- Worker
CREATE OR REPLACE VIEW flower_shop_views.workers AS
SELECT
    first_name, 
    LEFT(w.last_name, 1) || '****' AS masked_last_name,
    d.name AS department_name,
    LEFT(CAST(w.salary AS TEXT), 1) || '****' AS masked_salary
FROM flower_shop.Worker w
JOIN flower_shop.Department d ON w.department_id = d.department_id;

-- Order_X_Worker
CREATE OR REPLACE VIEW flower_shop_views.order_x_worker AS
SELECT
    LEFT(c.login, 2) || '****' AS masked_login,
    o.date AS order_date,
    LEFT(w.first_name, 1) || '****' || ' ' || LEFT(w.last_name, 1) || '****' AS worker_name
FROM flower_shop.Order_X_Worker ow
JOIN flower_shop."Order" o ON ow.order_id = o.order_id
JOIN flower_shop.Worker w ON ow.worker_id = w.worker_id
JOIN flower_shop.Client c ON o.client_id = c.client_id;