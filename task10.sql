set search_path = flower_shop,
    public;
DROP TABLE IF EXISTS flower_shop.stock_changes;
CREATE TABLE flower_shop.stock_changes (
    change_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES flower_shop.Product(product_id),
    supply_id INTEGER REFERENCES flower_shop.Supply(supply_id),
    change_amount INTEGER,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DROP TABLE IF EXISTS flower_shop.order_price_audit;
CREATE TABLE flower_shop.order_price_audit (
    audit_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES flower_shop."Order"(order_id),
    expected_price NUMERIC(10, 2),
    actual_price NUMERIC(10, 2),
    audit_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Обновление количества доступных товаров на складе после поступления новой поставки. Процедура также проверяет (вместо просто увеличения), существует ли поставка с указанным supply_id. Результаты в отдельной таблице stock_changes.
DROP FUNCTION IF EXISTS flower_shop.update_stock_after_supply(INTEGER);
CREATE OR REPLACE FUNCTION flower_shop.update_stock_after_supply(new_supply_id INTEGER) RETURNS VOID AS $$
DECLARE supply_record RECORD;
BEGIN IF NOT EXISTS (
    SELECT 1
    FROM flower_shop.Supply
    WHERE supply_id = new_supply_id
) THEN RAISE EXCEPTION 'Поставка с ID % не найдена.',
new_supply_id;
END IF;
FOR supply_record IN
SELECT *
FROM flower_shop.Product_X_Supply
WHERE supply_id = new_supply_id LOOP
UPDATE flower_shop.Product
SET number_of_remaining = number_of_remaining + supply_record.amount
WHERE product_id = supply_record.product_id;
INSERT INTO flower_shop.stock_changes (product_id, supply_id, change_amount)
VALUES (
        supply_record.product_id,
        new_supply_id,
        supply_record.amount
    );
END LOOP;
END;
$$ LANGUAGE plpgsql;
-- Процедура фиксирует время проведения аудита и количество найденных несоответствий. Аудит цен заказов, начиная с указанной даты, и сохраняет несоответствия в таблицу order_price_audit
DROP FUNCTION IF EXISTS flower_shop.audit_order_prices(DATE);
CREATE OR REPLACE FUNCTION flower_shop.audit_order_prices(start_date DATE DEFAULT '2000-01-01') RETURNS VOID AS $$ BEGIN TRUNCATE TABLE flower_shop.order_price_audit;
INSERT INTO flower_shop.order_price_audit (
        order_id,
        expected_price,
        actual_price,
        audit_timestamp
    )
SELECT o.order_id,
    SUM(oxp.amount * p.price) AS expected_price,
    o.price AS actual_price,
    date_trunc('minute', CURRENT_TIMESTAMP) AS audit_timestamp
FROM flower_shop."Order" o
    JOIN flower_shop.Product_X_Order oxp ON o.order_id = oxp.order_id
    JOIN flower_shop.Product p ON oxp.product_id = p.product_id
WHERE o.date >= start_date
GROUP BY o.order_id,
    o.price
HAVING SUM(oxp.amount * p.price) <> o.price;
END;
$$ LANGUAGE plpgsql;