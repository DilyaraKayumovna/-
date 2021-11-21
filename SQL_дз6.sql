--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".

select film_id, title, special_features
from film 
where special_features && array['Behind the Scenes']
order by film_id 

--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.

select film_id, title, special_features
from film 
where 'Behind the Scenes' = any(special_features)
order by film_id 

select film_id, title, special_features
from film 
where  special_features @> array['Behind the Scenes']
order by film_id 

 
--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.

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

--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.


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



--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������


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


--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:

--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������
--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������

--1. ����� � ������� ���������� ������� � ������������� ���������� "&&" � "@>"
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

--2. �������� ����������
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

