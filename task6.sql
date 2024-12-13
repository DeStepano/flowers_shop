set search_path = flower_shop,
    public;

-- Найти количество различных товаров, заказанных каждым клиентом, 
-- с фильтрацией клиентов, у которых более 10 товаров
SELECT 
    c.first_name || ' ' || c.last_name AS client_name,
    COUNT(pxo.product_id) AS total_products
FROM flower_shop.Client c
JOIN flower_shop."Order" o ON c.client_id = o.client_id
JOIN flower_shop.Product_X_Order pxo ON o.order_id = pxo.order_id
GROUP BY c.client_id
HAVING COUNT(pxo.product_id) > 10;


-- Получить список заказов с указанием клиента и их общей стоимости, 
-- отсортированный по убыванию стоимости
SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS client_name,
    o.price
FROM flower_shop."Order" o
JOIN flower_shop.Client c ON o.client_id = c.client_id
ORDER BY o.price DESC;


-- Вычислить среднюю зарплату сотрудников по отделам
SELECT 
    d.name AS department_name,
    ROUND(AVG(w.salary), 2) AS average_salary
FROM flower_shop.Department d
JOIN flower_shop.Worker w ON d.department_id = w.department_id
GROUP BY d.department_id;

-- Вывести заказы, обрабатываемые сотрудниками, включая номер заказа, 
-- имя сотрудника и общее количество обработанных заказов каждым сотрудником.
SELECT 
    o.order_id,
    w.first_name || ' ' || w.last_name AS worker_name,
    COUNT(o.order_id) OVER (PARTITION BY w.worker_id) AS total_orders
FROM flower_shop.Order_X_Worker oxw
JOIN flower_shop."Order" o ON oxw.order_id = o.order_id
JOIN flower_shop.Worker w ON oxw.worker_id = w.worker_id;

-- Рассчитать скользящую среднюю цену 
-- заказов за последние 3 заказа для каждого клиента
SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS client_name,
    o.price,
    ROUND(
        AVG(o.price) OVER (
            PARTITION BY o.client_id 
            ORDER BY o.date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_price
FROM flower_shop."Order" o
JOIN flower_shop.Client c ON o.client_id = c.client_id
ORDER BY c.client_id, o.date;

-- Найти сотрудников, чья зарплата превышает 
-- среднюю зарплату в их отделе более чем на 20%
WITH salary_analysis AS (
    SELECT 
        w.first_name || ' ' || w.last_name AS worker_name,
        d.name AS department_name,
        w.salary,
        AVG(w.salary) OVER (PARTITION BY d.department_id) AS avg_department_salary,
        (w.salary - AVG(w.salary) OVER (PARTITION BY d.department_id)) * 100.0 / 
            AVG(w.salary) OVER (PARTITION BY d.department_id) AS salary_difference_percent
    FROM flower_shop.Worker w
    JOIN flower_shop.Department d ON w.department_id = d.department_id
)
SELECT *
FROM salary_analysis
WHERE salary > 1.2 * avg_department_salary
ORDER BY salary_difference_percent DESC;


-- Определить клиентов, которые сделали заказы на сумму 
-- выше средней в каждом месяце прошлого года, 
-- и посчитать, сколько раз они это сделали
WITH monthly_averages AS (
    SELECT 
        DATE_TRUNC('month', date) AS order_month,
        AVG(price) AS avg_monthly_price
    FROM flower_shop."Order"
    WHERE date >= DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year'
      AND date < DATE_TRUNC('year', CURRENT_DATE)
    GROUP BY DATE_TRUNC('month', date)
)
SELECT 
    c.first_name || ' ' || c.last_name AS client_name,
    COUNT(*) AS months_above_average
FROM flower_shop.Client c
JOIN flower_shop."Order" o ON c.client_id = o.client_id
JOIN monthly_averages ma ON DATE_TRUNC('month', o.date) = ma.order_month
WHERE o.date >= DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year'
  AND o.date < DATE_TRUNC('year', CURRENT_DATE)
  AND o.price > ma.avg_monthly_price
GROUP BY c.client_id
HAVING COUNT(*) > 0
ORDER BY months_above_average DESC;