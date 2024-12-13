set search_path = flower_shop, public;


-- table "client"

select first_name, last_name from flower_shop.client;

insert into flower_shop.client(first_name, last_name, login, password)
    values ('Жанна', 'Ситцева', 'janna77', 'password103');

update flower_shop.client
    set login = 'Julia898', password = 'pupupupu'
where first_name = 'Юлия' AND last_name = 'Морозова';

SELECT * 
FROM flower_shop.client
ORDER BY client_id;

delete from flower_shop.client
where first_name = 'Жанна' AND last_name = 'Ситцева';

-- table "product"

select name_flower, price from product
where price >= 220
order by price desc;

insert into product(name_flower, description, price, number_of_remaining)
    values ('Кактус', 'Как в Смешариках' , 33000.00, 1);

update product
    set description = 'с белым цветком'
where name_flower = 'Кактус';

delete from product
where name_flower = 'Кактус';