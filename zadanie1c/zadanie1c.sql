create database retail;

create table retail_sales (
    invoice_no varchar(20),
    stock_code varchar(50),
    description text,
    quantity int,
    invoice_date timestamp,
    unit_price decimal(10,2),
    customer_id int,
    country varchar(100)
);
alter database retail set DateStyle to 'German';
show datestyle;

select * from retail_sales;
select *, (quantity * unit_price) as trzba, sum(quantity * unit_price) over (partition by customer_id order by invoice_date range between interval '14 days' preceding and current row) as revenue from retail_sales where customer_id is not null order by customer_id, invoice_date asc;

select stock_code, country, invoice_date, quantity, round(avg(quantity) over (partition by stock_code, country order by invoice_date range between interval '7 days' preceding and current row), 2) as avg_quantity_7_days from retail_sales where quantity > 1 order by stock_code, country, invoice_date;

with dota AS
(select distinct customer_id, invoice_no, invoice_date from retail_sales),
dotb AS
(select customer_id,invoice_no,invoice_date,lead(invoice_date, 1) over (partition by customer_id order by invoice_date) as next_invoice_date from dota)
SELECT
*,
(next_invoice_date::date - invoice_date::date) as days_to_next_invoice
from dotb
where next_invoice_date is not null
order by days_to_next_invoice desc;

with dota AS
(select 
stock_code,
invoice_no,
invoice_date,
lag(unit_price, 1) over (partition by stock_code order by invoice_date) as previous_price,
unit_price as current_price
from retail_sales)
SELECT
*,
(current_price - previous_price) as price_difference
from dota
where previous_price is not null and current_price <> previous_price
order by invoice_date asc;

with dota AS
(select customer_id, sum(quantity * unit_price) as total_amount from retail_sales where customer_id is not null group by customer_id)
SELECT
customer_id,
ntile(4) over (order by total_amount desc) as sales_quartile
from dota
order by total_amount desc;

with dota as(
    select country, date_trunc('month',invoice_date)::date as month, sum(quantity*unit_price) as total_amount from retail_sales group by country,date_trunc('month',invoice_date)::date
)
select country, month, total_amount, ntile(4) over(partition by country order by total_amount desc) as sales_quartile from dota order by country, month asc;

with dota as (
    select customer_id, invoice_date,invoice_no,stock_code,quantity,unit_price, row_number() over (partition by customer_id order by invoice_date asc) as num from retail_sales where customer_id is not null
)
SELECT
customer_id,
invoice_no,
invoice_date,
stock_code,
quantity,
unit_price
from dota
where num = 1
order by customer_id asc;

with dota as (select invoice_no, stock_code, description, quantity, unit_price, (quantity * unit_price) as amount, row_number() over (partition by invoice_no order by (quantity * unit_price) desc) from retail_sales)
SELECT *
from dota
where row_number = 1 or row_number = 3;

with dota as(
select 
country,
date_trunc('month', invoice_date)::date as month, 
customer_id,
sum(quantity * unit_price) as total_amount
from retail_sales
group by country, customer_id, date_trunc('month', invoice_date)::date),
dotb as (
    select *, dense_rank() over (partition by country,month order by total_amount desc) as sales_rank from dota
)
select * from dotb where sales_rank <= 5 order by country asc, month asc,sales_rank asc, customer_id asc;

with dota as (
select
invoice_no,
stock_code,
description,
quantity,
unit_price,
dense_rank() over(partition by invoice_no order by unit_price desc) as price_rank
from retail_sales)
select *
from dota
where price_rank <= 5
order by invoice_no,price_rank,stock_code;
