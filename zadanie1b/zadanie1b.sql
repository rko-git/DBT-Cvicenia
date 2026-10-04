create database datacraftinglab_db;

create table flourmills_sales (
    sales_id int PRIMARY KEY,
    sale_date date,
    region varchar(100),
    state varchar(100),
    product_category varchar(100),
    product_name varchar(150),
    customer_type varchar(100),
    customer_id int,
    quantity_sold int,
    unit_price decimal(10, 2),
    discount_rate int,
    payment_method varchar(100),
    sales_rep varchar(150),
    warehouse varchar(100),
    delivery_status varchar(100),
    order_channel varchar(100),
    batch_number int,
    production_date date,
    total_amount decimal(10, 2)
)

select * from flourmills_sales;
select total_amount from flourmills_sales;
select product_name, total_amount from flourmills_sales where total_amount > (select avg(total_amount) from flourmills_sales) limit 4028;


with kategorie as (select sum(total_amount) as celkovo, product_category from flourmills_sales group by product_category ) select sales_id, sale_date, region, product_category from flourmills_sales where product_category = (select product_category from kategorie where celkovo = (select max(celkovo) from kategorie));

select product_name, total_amount, (select avg(total_amount) from flourmills_sales) as avg_amount from flourmills_sales where total_amount = 9511208.41;

select product_name, total_amount, total_amount / (select sum(total_amount) from flourmills_sales) as amount_share from flourmills_sales;

select * from (select extract(month from sale_date) as month, sum(total_amount) as monthly_sales from flourmills_sales group by month ) order by monthly_sales desc;

select * from (select product_category, sum(total_amount) as total_sales from flourmills_sales group by product_category ) where total_sales > 50000000 order by total_sales desc;

select count(*) from flourmills_sales t1 where total_amount > (select avg(total_amount) from flourmills_sales t2 where t2.product_category = t1.product_category);

select product_name, region, total_amount, (select min(total_amount) from flourmills_sales t2 where t2.region = t1.region group by region) as region_min_amount from flourmills_sales t1;

select t1.* from flourmills_sales t1 where exists (select 1 from flourmills_sales t2 where t2.product_name = t1.product_name and (extract(year from t2.sale_date) <> extract(year from t1.sale_date) or extract(month from t2.sale_date) <> extract(month from t1.sale_date)));

select t1.product_category, t1.product_name, t1.total_amount from flourmills_sales t1 where exists (select 1 from flourmills_sales t2 where t2.product_category = t1.product_category and t2.total_amount > 200000);

select distinct t1.product_category from flourmills_sales t1 where exists (select 1 from flourmills_sales t2 where t2.product_category = t1.product_category group by t2.product_category having count(distinct region) > 3);

select t1.* from flourmills_sales t1 where exists (select 1 from flourmills_sales t2 where t2.region = t1.region and extract(year from t2.sale_date) = 2024);

select count(distinct t1.product_category) from flourmills_sales t1 where not exists (select 1 from flourmills_sales t2 where t2.product_category = t1.product_category and t2.total_amount > 500000);

select distinct t1.region from flourmills_sales t1 where not exists (select 1 from flourmills_sales t2 where t2.region = t1.region and t2.product_category like '%Flour%');