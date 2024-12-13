-- TASK 4 --

TRUNCATE TABLE flower_shop.Worker RESTART IDENTITY CASCADE; // удалить таблицу 



TRUNCATE TABLE flower_shop.Product_X_Order RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Product_X_Supply RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Supply RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Order_X_Worker RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop."Order" RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Client RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Worker RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Department RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Product RESTART IDENTITY CASCADE;
TRUNCATE TABLE flower_shop.Supplier RESTART IDENTITY CASCADE;

//удалить все таблицы 


-- TASK 10 --

testing: 
SELECT flower_shop.update_stock_after_supply(11);
SELECT flower_shop.update_stock_after_supply(12);


-- просмотр данных 
SELECT * FROM flower_shop.stock_changes
ORDER BY change_id;

SELECT product_id, name_flower, number_of_remaining
FROM flower_shop.Product
ORDER BY product_id;