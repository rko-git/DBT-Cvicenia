create view high_value_customers as select c.customer_id, c.customer_name, sum(o.sales) as total_sales from customers c inner join orders o on c.customer_id = o.customer_id group by c.customer_id having sum(o.sales) > 2000;

select * from high_value_customers;

create view regional_monthly_sales as select c.region, date_trunc('month', order_date) as month, sum(o.sales) as monthly_sales from customers c inner join orders o on c.customer_id = o.customer_id group by c.region, month;

select * from regional_monthly_sales where region = 'West';

create view analyst_orders as select order_id, customer_id, product_id, sales, quantity, discount from orders;

select * from analyst_orders;

create index idx_customer_id on orders(customer_id);

select customer_id from orders where customer_id = 'C001';

create index idx_orders_order_date on orders(order_date);

select date_trunc('month', order_date) as month, sum(sales) from orders group by month order by month asc;

create index idx_orders_region_category on orders(customer_id, order_date);

select o.* from orders o inner join customers c on o.customer_id = c.customer_id where c.region = 'West';

explain analyze select * from orders where customer_id = 'C001';

create database retail_sales;


create table orders(
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    order_date DATE,
    region VARCHAR(20),
    category VARCHAR(50),
    ship_mode VARCHAR(30),
    sales DECIMAL(10, 2),
    profit DECIMAL(10, 2)
);

alter database retail_sales set DateStyle to 'ISO, MDY';

select * from orders;

create or replace procedure get_customer_sales (p_customer_id VARCHAR(20))
language plpgsql
as $$
declare
    total_sales DECIMAL(10, 2);
    record_count INT;
begin
    select sum(sales), count(*) into total_sales, record_count from orders where customer_id = p_customer_id;

    raise notice 'Zákazník: %, Celkový predaj: %, Počet záznamov: %', p_customer_id, total_sales, record_count;
end;
$$;

call get_customer_sales('C001');

create procedure apply_regional_discount (region_name VARCHAR(20), discount_rate DECIMAL(5, 2))
language plpgsql
as $$
begin
    update orders set sales = sales * (1 - discount_rate / 100) from customers where region = region_name;

    raise notice 'Aplikovaná zľava: % pre región: %', discount_rate, region_name;
end;
$$;

CALL apply_regional_discount('West', 0.10);

create procedure get_sales_between (p_start_date DATE, p_end_date DATE)
language plpgsql
as $$
declare
    total_sales DECIMAL(10, 2);
begin
    select sum(sales) into total_sales from orders where order_date between p_start_date and p_end_date;

    raise notice 'Obdobie od % do %, Celkový predaj: %', p_start_date, p_end_date, total_sales;
end;
$$;

call get_sales_between('2024-01-01', '2024-03-31');

select * from flourmills_sales;
with daily_sales as (select sale_date, sum(total_amount) as total_daily_sales from flourmills_sales group by sale_date) select * from daily_sales where total_daily_sales > 3000000 order by total_daily_sales desc;

with dotaz as (select product_category, sum(total_amount) as category_sales from flourmills_sales group by product_category) select * from dotaz order by category_sales desc;

with dota as (select product_category, product_name, sum(total_amount) as total_product_sales from flourmills_sales group by product_category, product_name), dotb as (select product_category, product_name, total_product_sales, rank() over (partition by product_category order by total_product_sales desc) as category_rank from dota) select product_category, product_name, total_product_sales, category_rank from dotb where category_rank <= 3 order by product_category asc, category_rank asc;

with dota as (select customer_type, sum(total_amount) as revenue from flourmills_sales group by customer_type), dotb as (select customer_type, revenue, sum(revenue) over (partition by customer_type) as total_revenue, round(revenue /sum(revenue) over () * 100, 2) as revenue_percentage from dota) select customer_type, revenue, total_revenue, revenue_percentage from dotb order by revenue desc;

with dota as (select customer_id, product_name, sale_date,total_amount, row_number() over(partition by customer_id order by sale_date desc) as row_num from flourmills_sales) select customer_id, product_name, sale_date, total_amount from dota where row_num = 1 order by customer_id asc;

with recursive bounds as (select min(sale_date) as min_date, max(sale_date) as max_date from flourmills_sales), cal(sale_date, max_date) as (select min_date as sale_date, max_date from bounds union all select (sale_date + interval '1 day'), max_date from cal where sale_date < max_date) select sale_date from cal order by sale_date asc;

