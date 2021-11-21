--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id 

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

select film_id, title, special_features
from film 
where 'Behind the Scenes' = any(special_features)
order by film_id 

select film_id, title, special_features
from film 
where  special_features @> array['Behind the Scenes']
order by film_id 

 
--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

with cte as(
select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id 
)
select c.customer_id, count(cte.film_id) as film_count
from cte 
join inventory i on i.film_id = cte.film_id 
join rental r on r.inventory_id = i.inventory_id 
join customer c on r.customer_id = c.customer_id 
group by c.customer_id 
order by c.customer_id 

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.


select c.customer_id, count(ad.film_id) as film_count
from (
select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id) as ad
join inventory i on i.film_id = ad.film_id 
join rental r on r.inventory_id = i.inventory_id 
join customer c on r.customer_id = c.customer_id 
group by c.customer_id 
order by c.customer_id 



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления


create materialized view task_5 as
select c.customer_id, count(ad.film_id) as film_count
from (
select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id) as ad
join inventory i on i.film_id = ad.film_id 
join rental r on r.inventory_id = i.inventory_id 
join customer c on r.customer_id = c.customer_id 
group by c.customer_id 
order by c.customer_id 
with data

refresh materialized view task_5


--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

--1. Поиск в массиве происходит быстрее с использванием операторов "&&" и "@>"
explain analyze
select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id --92.25

explain analyze
select film_id, title, special_features
from film 
where 'Behind the Scenes' = any(special_features)
order by film_id --102.25

explain analyze
select film_id, title, special_features
from film 
where  special_features @> array['Behind the Scenes']
order by film_id --92.25

--2. Скорость одинаковая
explain analyze
with cte as(
select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id 
)
select c.customer_id, count(cte.film_id) as film_count
from cte 
join inventory i on i.film_id = cte.film_id 
join rental r on r.inventory_id = i.inventory_id 
join customer c on r.customer_id = c.customer_id 
group by c.customer_id 
order by c.customer_id --837.42

explain analyze
select c.customer_id, count(ad.film_id) as film_count
from (
select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id) as ad
join inventory i on i.film_id = ad.film_id 
join rental r on r.inventory_id = i.inventory_id 
join customer c on r.customer_id = c.customer_id 
group by c.customer_id 
order by c.customer_id --837.42

