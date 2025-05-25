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

- Each **order** references a **customer** and a **location**.
- Each **order item** references an **order** and a **product**.
- Each **location** references a **city**, and each **city** references a **state**.

⸻

## Normalization Rationale

To reduce redundancy and improve structure, performance, and maintainability, state and city data were moved into normalized tables using integer keys to ensure better data integrity and efficiency.

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

What would you add next?
- Data Visualization
- Export Entity-Relationship Diagram
 
