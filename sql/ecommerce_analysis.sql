-- Churn rate analysis
	-- Calculate churn rate using CTE for 2023 and 2024:
with customers_2023 as (
	select distinct customer_id
	from orders o
	where to_char(order_date, 'YYYY-MM') like '2023%'
	),

customers_2024 as (
	select distinct customer_id
	from orders o
	where to_char(order_date, 'YYYY-MM') like '2024%'
	)
	
select count(*)
from customers_2023
where customer_id not in (
	select customer_id from customers_2024
	);  


-- Regional sales analysis:
	-- Sales by region and profit 
select 
	s.state_name,
	sum (oi.amount) as total_sales,
	sum (oi.profit) as total_profit
from order_items oi 
join orders o on oi.order_uid = o.order_uid
join cities c on o.city_id = c.city_id 
join states s on s.state_id = c.state_id
group by s.state_name
order by total_profit desc; 

	-- Sales by cities 
select 
	s.state_name, 
	c.city_name, 
	sum(oi.amount) as total_sales, 
	sum(oi.profit) as total_profit 
from order_items oi
join orders o on oi.order_uid = o.order_uid
join cities c on o.city_id = c.city_id 
join states s on s.state_id = c.state_id
group by s.state_name, c.city_name
order by total_profit desc; 



-- Product performance
	--Identify profitable and least profitable products
select
	p.category,
	p.sub_category,
	sum(oi.profit) as total_profit, 
	sum (oi.amount) as total_sales
from order_items oi
join products p on p.product_id = oi.product_id
group by p.category, p.sub_category
order by total_profit desc; 


-- Most profitable year and profitable product
with profit_by_year as (
	select 
		to_char(order_date, 'YYYY') as year,
		sum (oi.profit) as total_profit,
		sum (oi.amount) as total_sales
	from orders o
	join order_items oi on o.order_uid = oi.order_uid 
	join products p on p.product_id = oi.product_id
	group by "year" 
	)	
select *
from profit_by_year
order by total_profit desc; 

