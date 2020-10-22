/*Lab | SQL Rolling calculations
In this lab, you will be using the Sakila database of movie rentals.

Instructions
Get number of monthly active customers.
Active users in the previous month.
Percentage change in the number of active customers.
Retained customers every month.*/
USE sakila;

-- Get number of monthly active customers.
create or replace view client_activity as
select customer_id, rental_date as Activity_date,
date_format(rental_date, '%m') as Activity_Month,
date_format(rental_date, '%Y') as Activity_year
from rental;
select * from client_activity;

create or replace view Monthly_active_clients as
select count(distinct customer_id) as Active_users, Activity_year, Activity_Month
from client_activity
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month;
select * from Monthly_active_clients;

-- Active users in the previous month.
with cte_activity as (
  select Active_users, lag(Active_users, 1, Active_users) over (partition by Activity_year) as last_month, Activity_year, Activity_month
  from Monthly_active_clients
)
select * from cte_activity
where last_month is not null;

-- Percentage change in the number of active customers
with cte_activity as (
  select Active_users, lag(Active_users, 1, Active_users) over (partition by Activity_year) as last_month, Activity_year, Activity_month
  from Monthly_active_clients
)
select *, round(((Active_users - last_month) * 100/last_month),2) as diff_percent from cte_activity
where last_month is not null;

-- Retained customers every month.
create or replace view retained_clients_view as
with distinct_users as (
  select distinct customer_id , Activity_Month, Activity_year
  from client_activity
)
select count(distinct d1.customer_id) as Retained_customers, d1.Activity_Month, d1.Activity_year
from distinct_users d1
join distinct_users d2 on d1.customer_id = d2.customer_id
and d1.activity_Month = d2.activity_Month + 1
group by d1.Activity_Month, d1.Activity_year
order by d1.Activity_year, d1.Activity_Month;
select * from retained_clients_view;