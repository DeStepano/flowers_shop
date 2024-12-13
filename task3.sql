DROP SCHEMA IF EXISTS flower_shop CASCADE;
CREATE SCHEMA flower_shop;
set search_path = flower_shop,
    public;
CREATE TABLE flower_shop.Supplier (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    contacts TEXT NOT NULL
);
CREATE TABLE flower_shop.Supply (
    supply_id SERIAL PRIMARY KEY,
    supplier_id INTEGER NOT NULL REFERENCES flower_shop.Supplier(supplier_id),
    date DATE NOT NULL
);
CREATE TABLE flower_shop.Product (
    product_id SERIAL PRIMARY KEY,
    name_flower TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10, 2),
    number_of_remaining INTEGER CHECK (number_of_remaining > 0)
);
ALTER TABLE flower_shop.Product
ADD CONSTRAINT price_positive CHECK (price > 0.00);
CREATE TABLE flower_shop.Product_X_Supply (
    supply_id INTEGER NOT NULL REFERENCES flower_shop.Supply(supply_id),
    product_id INTEGER NOT NULL REFERENCES flower_shop.Product(product_id),
    amount INTEGER CHECK (amount >= 0),
    PRIMARY KEY (supply_id, product_id)
);
CREATE TABLE flower_shop.Client (
    client_id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT,
    login TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL CHECK (LENGTH(password) >= 8)
);
CREATE TABLE flower_shop."Order" (
    order_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES flower_shop.Client(client_id),
    date DATE NOT NULL,
    status TEXT CHECK (
        status IN ('PAID', 'CANCELLED', 'DELIVERED', 'IN_PROGRESS')
    ),
    price NUMERIC(10, 2)
);
ALTER TABLE flower_shop."Order"
ADD CONSTRAINT price_positive CHECK (price > 0.00);
CREATE TABLE flower_shop.Product_X_Order (
    order_id INTEGER NOT NULL REFERENCES flower_shop."Order"(order_id),
    product_id INTEGER NOT NULL REFERENCES flower_shop.Product(product_id),
    amount INTEGER CHECK (amount >= 0),
    PRIMARY KEY (order_id, product_id)
);
CREATE TABLE flower_shop.Department (
    department_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);
CREATE TABLE flower_shop.Worker (
    worker_id SERIAL PRIMARY KEY,
    department_id INTEGER REFERENCES flower_shop.Department(department_id),
    first_name TEXT NOT NULL,
    last_name TEXT,
    salary NUMERIC(10, 2)
);
ALTER TABLE flower_shop.Worker
ADD CONSTRAINT salary_positive CHECK (salary > 0.00);
CREATE TABLE flower_shop.Order_X_Worker (
    worker_id INTEGER NOT NULL REFERENCES flower_shop.Worker(worker_id),
    order_id INTEGER NOT NULL REFERENCES flower_shop."Order"(order_id),
    PRIMARY KEY (worker_id, order_id)
);