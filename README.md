# Sales Database Project

## Table of Contents
- [Overview](#overview)
- [Dataset Source](#dataset-source)
- [Database Schema](#database-schema)
- [Relationships](#relationships)
- [Normalization Rationale](#normalization-rationale)
- [Schema Definition (SQL)](#schema-definition-sql)
- [Data Quality Issue](#data-quality-issue)
- [Sample Queries](#sample-queries)
- [Setup Instructions](#setup-instructions)
- [Key Findings](#key-findings)
- [Future Work](#future-work)

## Overview

A normalized sales database designed for learning and practicing SQL in a real-world analytics context, using data from an online eCommerce business. Initial data profiling was performed in Excel to identify redundancy, groupings, and normalization opportunities before designing the relational schema in SQL. This project demonstrates the process of normalizing a raw sales dataset and building a relational database to support SQL-based business analysis. The dataset comes from an online U.S. eCommerce business.

## Dataset Source

The dataset is a clean csv with no missing values. It consists of 1,194 sales records, including customer names, product categories, profits, and locations across U.S. states. Raw dataset can be found [here](./data/sales_dataset.csv).  

## Database Schema

### Tables

- `customers` – *Stores customer information*
- `states` – *Stores U.S. states where orders were placed*
- `cities` – *Stores cities linked to states*
- `products` – *Stores product categories and sub-categories*
- `orders` – *Stores order-level data (date, customer, location, payment mode)*
- `order_items` – *Stores line items per order (product, quantity, amount, profit)*

## Relationships

- Each **order** references a **customer** and a **city**.
- Each **order item** references an **order** and a **product**.
- Each **city** references a **state**.

## Normalization Rationale

To reduce redundancy and improve structure, performance, and maintainability, state and city data were moved into normalized tables using integer keys to ensure better data integrity and efficiency.

## Schema Definition (SQL)
```sql
CREATE TABLE public.sales_raw (
	"Order ID" varchar NULL,
	amount int4 NULL,
	profit int4 NULL,
	quantity int4 NULL,
	category varchar NULL,
	"Sub-Category" varchar NULL,
	paymentmode varchar NULL,
	"Order Date" date NULL,
	customername varchar NULL,
	state varchar NULL,
	city varchar NULL,
	year_month varchar NULL
);

CREATE TABLE public.customers (
	customer_id int4 GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_name varchar NOT NULL,
	UNIQUE (customer_name)
);

CREATE TABLE public.states (
	state_id int4 GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	state_name varchar NOT NULL
);

CREATE TABLE public.cities (
	city_id int4 GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	city_name varchar NOT NULL,
	state_id int4 NOT NULL,
	FOREIGN KEY (state_id) REFERENCES public.states(state_id)
);

CREATE TABLE public.products (
	product_id int4 GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category varchar NOT NULL,
	sub_category varchar NOT NULL
);

CREATE TABLE public.orders (
	order_uid int4 GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	order_id varchar,
	order_date date NOT NULL,
	customer_id int4 NOT NULL,
	city_id int4 NOT NULL,
	payment_mode varchar NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id),
	FOREIGN KEY (city_id) REFERENCES public.cities(city_id)
);

CREATE TABLE public.order_items (
	item_id int4 GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	order_uid int4 NOT NULL,
	product_id int4 NOT NULL,
	quantity int4 NOT NULL,
	amount int4 NOT NULL,
	profit int4 NOT NULL,
	FOREIGN KEY (order_uid) REFERENCES public.orders(order_uid),
	FOREIGN KEY (product_id) REFERENCES public.products(product_id)
);
```

## Data Quality Issue

During analysis, it was discovered that the Order ID column in the raw dataset was not a reliable unique identifier. Multiple rows shared the same Order ID but had different order dates, customer names and locations. This inconsistency led to inaccurate data mapping and duplication when populating the orders and order_items tables.

### Resolution: 
- A surrogate primary key order_uid was introduced in the orders table.
- Instead of using Order ID, records were matched based on Order Date, Customer Name, City, and Payment Mode.
- This ensured one-to-one matching and prevented duplicate entries. 

## Sample Queries

#### 📊 Churn Rate Analysis
``` sql
with
  customers_2023 as  (
    select distinct customer_id
    from orders
    where to_char(order_date, 'YYYY') = '2023'
  ),
  customers_2024 as (
    select distinct customer_id
    from orders
    where to_char(order_date, 'YYYY') = '2024'
  ),
  churned as (
    select customer_id
    from customers_2023
    where customer_id not in (select customer_id from customers_2024)
  )
select
  count(*) as churned_customers,
  (select count(*) from customers_2023) as total_2023_customers,
  round(100.0 * count(*) / (select count(*) from customers_2023), 2) as churn_rate_percent
from churned; 
```

#### 🗺️ Regional Sales Analysis
``` sql
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
```

#### 📈 Most Profitable Year
``` sql
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
```

## Setup Instructions

To recreate setup:
- Clone the repository
- Open DBeaver and connect to your database
- Run the `CREATE TABLE` scripts provided
- The raw dataset is located in `/data/sales_dataset.csv`. Import the CSV into the appropriate tables using DBeaver's data import tool. 
- Run queries from sample SQL file or notebook

Ensure PostgreSQL is installed and running. After importing, run the queries listed under ‘Sample Queries’ or your own exploratory SQL.

## Key Findings: 
- **Churn Rate**  
  A 100% churn rate was observed between 2023 and 2024, indicating none of the customers who purchased in 2023 returned in 2024.

- **Regional Performance**  
  - **Top Performing State**: *Florida*  
    - Total Sales: $1,091,174  
    - Total Profit: $308,706  
  - **Lowest Performing State**: *Ohio*  
    - Total Sales: $884,768  
    - Total Profit: $216,519  

- **City-Level Insights**  
  - **Top Performing City**: *Orlando, Florida*  
    - Total Sales: $452,158  
    - Total Profit: $128,125  
  - **Lowest Performing City**: *Columbus, Ohio*  
    - Total Sales: $246,692  
    - Total Profit: $56,277  

- **Product Performance**  
  - **Most Profitable Product**: *Markers* (Office Supplies)  
    - Total Sales: $627,875  
    - Total Profit: $174,749  
  - **Least Profitable Product**: *Binders* (Office Supplies)  
    - Total Sales: $384,611  
    - Total Profit: $97,257  

- **Yearly Sales Trends**  
  - **Most Profitable Year**: *2022*  
    - Total Sales: $1,459,775  
    - Total Profit: $393,113  
  - **Least Profitable Year**: *2020*  
    - Total Sales: $859,401  
    - Total Profit: $224,103  
  - Notable Growth: From 2020 to 2022, sales increased by $600,374.  
  - **Other Notable Years**:  
    - *2023*: $1,229,723 in sales, $321,671 in profit  
    - *2024*: $1,202,478 in sales, $308,336 in profit  

## Future Work

What would be added next?
- Data Visualization
- Export Entity-Relationship Diagram
 
