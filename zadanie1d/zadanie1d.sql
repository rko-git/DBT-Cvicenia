with dota as (select customer_id, order_id, order_date, row_number() over (partition by customer_id order by order_date desc) as number from orders)
SELECT
c.customer_name,
d.order_id,
d.order_date,
d.number
from dota d
inner join customers c
on d.customer_id = c.customer_id
WHERE
d.number <= 2
order by customer_name asc, number asc;

with dota as (
    SELECT
    c.region,
    c.customer_name,
    sum(o.profit) as total_profit
    from customers c
    inner join orders o
    on c.customer_id = o.customer_id
    group by c.region, c.customer_name
)
SELECT
*,
rank() over(partition by region order by total_profit desc) as profit_rank,
dense_rank() over(partition by region order by total_profit desc) as profit_dense_rank
from dota
order by region asc, profit_rank asc, profit_dense_rank asc;

with dota as (
    SELECT
    customer_id,
    sum(sales) as total_sales
    from orders
    group by customer_id
)
SELECT
c.customer_name,
d.total_sales,
ntile(4) over (order by total_sales desc) as quartile
from customers c 
inner join dota d 
on c.customer_id = d.customer_id
order by total_sales desc;

with dota as (
    SELECT
    date_trunc('month', order_date)::date as month,
    sum(sales) as monthly_sales
    from orders
    group by month
)
SELECT
*,
lag(monthly_sales,1) over (order by month) as prev_month_sales,
lead(monthly_sales,1) over(order by month) as next_month_sales
from dota
order by month asc;

with dota as (
    select
    p.product_id,
    p.category,
    p.product_name,
    SUM(o.sales) AS product_sales
    from products p
    inner join orders o 
    on p.product_id = o.product_id
    group by p.product_id,p.product_name, p.category
)
SELECT 
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        product_sales * 100.0 /
        SUM(product_sales) OVER (PARTITION BY category),
        2
    ) AS pct_of_category
FROM dota
ORDER BY
category asc,
product_name asc;

with dota as (
SELECT
c.customer_id,
c.customer_name,
max(o.order_date::date) over (partition by c.customer_id) as last_order_date,
max(o.order_date::date) over () as latest_order_date
from customers c
inner join orders o
on c.customer_id = o.customer_id)
SELECT
*
from dota
WHERE
last_order_date < latest_order_date - interval '90 days'
order by last_order_date asc;

with dota as (
    SELECT
    date_trunc('month', order_date)::date as month,
    sum(sales) as monthly_sales
    from orders
    group by month
),
dotb as (
SELECT
*,
lag(monthly_sales,1) over (order by month) as prev_month_sales
from dota
)
SELECT
*,
(monthly_sales - prev_month_sales) as sales_change,
round(((monthly_sales - prev_month_sales) / prev_month_sales) * 100,2) as growth_percentage
from dotb
order by month;

select * from orders

with dota as (
    SELECT
    count(distinct customer_id) as pocet
    from orders
    where extract(month from order_date) = 6 and extract(year from order_date) = 2024)
SELECT
*
from dota;