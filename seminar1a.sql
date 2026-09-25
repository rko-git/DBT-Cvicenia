CREATE DATABASE superstore;

create table customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

create table products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

create table orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20), FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    product_id VARCHAR(20), FOREIGN KEY(product_id) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(10,2),
    profit DECIMAL(10,2)
);

select * from customers;
select * from products;
select * from orders;

select o.order_id, c.customer_name, o.sales from orders o inner join customers c on o.customer_id = c.customer_id where o.sales > 500 order by sales desc;

select o.order_id, c.customer_name, p.category, o.sales from orders o inner join customers c on o.customer_id = c.customer_id inner join products p on o.product_id = p.product_id;

select c.region, sum(o.sales) from customers c left join orders o on c.customer_id = o.customer_id group by c.region;

select p.product_name, sum(o.sales) from products p left join orders o on p.product_id = o.product_id group by p.product_name;

select c.customer_name, o.order_id, o.sales from customers c inner join orders o on c.customer_id = o.customer_id;

select c.customer_name, count(o.*) from customers c left join orders o on c.customer_id = o.customer_id group by c.customer_name;

select p.category, avg(o.discount) from products p inner join orders o on p.product_id = o.product_id group by p.category;

select c.customer_name, sum(o.sales) from customers c inner join orders o on c.customer_id = o.customer_id group by c.customer_name having sum(o.sales) > 2000;

select c.region, sum(o.sales), avg(o.discount), count(o.order_id) from customers c inner join orders o on c.customer_id = o.customer_id group by c.region

select c.region, count(case when o.sales > 1000 then 1 end) as "high-value", count(case when o.sales <= 1000 then 1 end) as "low-value" from customers c inner join orders o on c.customer_id = o.customer_id group by c.region;

select c.customer_name, sum(o.sales), avg(o.discount), count(o.order_id), case when sum(o.sales) > 2500 then 'VIP' else 'Regular' end as typ from customers c inner join orders o on c.customer_id = o.customer_id group by c.customer_name;