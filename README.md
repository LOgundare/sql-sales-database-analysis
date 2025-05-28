# Sales Database Project

## Overview

A normalized sales database designed for learning and practicing SQL in a real-world analytics context, using data from an online eCommerce business. Initial data profiling was performed in Excel to identify redundancy, groupings, and normalization opportunities before designing the relational schema in SQL.

⸻

## Dataset Source

The dataset is a clean csv with no missing values. It consists of 1,194 sales records, including customer names, product categories, profits, and locations across U.S. states. Raw dataset can be found [here](./data/sales_dataset.csv).  

⸻

## Database Schema

### Tables

- `customers` – *Stores customer information*
- `states` – *Stores U.S. states where orders were placed*
- `cities` – *Stores cities linked to states*
- `products` – *Stores product categories and sub-categories*
- `orders` – *Stores order-level data (date, customer, location, payment mode)*
- `order_items` – *Stores line items per order (product, quantity, amount, profit)*

⸻

## Relationships

- Each **order** references a **customer** and a **city**.
- Each **order item** references an **order** and a **product**.
- Each **city** references a **state**.

⸻

## Normalization Rationale

To reduce redundancy and improve structure, performance, and maintainability, state and city data were moved into normalized tables using integer keys to ensure better data integrity and efficiency.

⸻

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
⸻

## Data Quality Issue

During analysis, it was discovered that the Order ID column in the raw dataset was not a reliable unique identifier. Multiple rows shared the same Order ID but had different order dates, customer names and locations. This inconsistency led to inaccurate data mapping and duplication when populating the orders and order_items tables.

### Resolution: 
- A surrogate primary key order_uid was introduced in the orders table.
- Instead of using Order ID, records were matched based on Order Date, Customer Name, City, and Payment Mode.
- This ensured one-to-one matching and prevented duplicate entries. 

⸻

## Sample Queries

*to be completed after analysis is finalized*

⸻

## Setup Instructions

To recreate setup:
- Clone the repository
- Open DBeaver and connect to your database
- Run the `CREATE TABLE` scripts provided
- The raw dataset is located in `/data/sales_dataset.csv`. Import the CSV into the appropriate tables using DBeaver's data import tool. 
- Run queries from sample SQL file or notebook

⸻

## Future Work

What would be added next?
- Data Visualization
- Export Entity-Relationship Diagram
 
