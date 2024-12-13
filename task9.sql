-- Триггер 1: Автоматическое обновление остатка товара при создании заказа
DROP TRIGGER IF EXISTS trg_update_product_quantity ON flower_shop.Product_X_Order;


-- Создание функции триггера для обновления остатка товара
CREATE OR REPLACE FUNCTION update_product_quantity()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка, достаточно ли товара на складе
    IF (SELECT number_of_remaining FROM flower_shop.Product WHERE product_id = NEW.product_id) < NEW.amount THEN
        RAISE EXCEPTION 'Недостаточно товара (ID: %) на складе. Требуется: %, доступно: %', NEW.product_id, NEW.amount, 
            (SELECT number_of_remaining FROM flower_shop.Product WHERE product_id = NEW.product_id);
    END IF;

    -- Обновление количества оставшегося товара
    UPDATE flower_shop.Product
    SET number_of_remaining = number_of_remaining - NEW.amount
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера на вставку в таблицу Product_X_Order
CREATE TRIGGER trg_update_product_quantity
BEFORE INSERT ON flower_shop.Product_X_Order
FOR EACH ROW
EXECUTE FUNCTION update_product_quantity();


-- Триггер 2: Автоматическое обновление статуса заказа
-- Логика: Если все товары в заказе доставлены (в таблице Product_X_Order их количество становится равным 0), 
-- статус заказа в таблице Order автоматически меняется на DELIVERED.
DROP TRIGGER IF EXISTS check_order_completion ON flower_shop.Product_X_Order;


-- Создание триггерной функции
CREATE OR REPLACE FUNCTION update_order_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM flower_shop.Product_X_Order
        WHERE order_id = NEW.order_id AND amount > 0
    ) THEN
        UPDATE flower_shop."Order"
        SET status = 'DELIVERED'
        WHERE order_id = NEW.order_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера
CREATE TRIGGER check_order_completion
AFTER UPDATE OF amount ON flower_shop.Product_X_Order
FOR EACH ROW
WHEN (OLD.amount IS DISTINCT FROM NEW.amount)
EXECUTE FUNCTION update_order_status();



