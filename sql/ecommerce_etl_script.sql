 
-- Step 1: Initial Data Profiling
SELECT DISTINCT category FROM sales_raw;
SELECT COUNT(*) FROM sales_raw;

-- Step 2: Populate Dimension Tables
INSERT INTO customers (customer_name)
SELECT DISTINCT customername FROM sales_raw;

INSERT INTO products (category, sub_category)
SELECT DISTINCT category, "Sub-Category" FROM sales_raw;

INSERT INTO states (state_name)
SELECT DISTINCT state FROM sales_raw;

-- Step 3: Populate Cities with Synthetic Keys
INSERT INTO cities (city_id, city_name, state_id)
OVERRIDING SYSTEM VALUE
SELECT 
  (state_id * 100) + ROW_NUMBER() OVER (PARTITION BY state_id ORDER BY city) AS city_id,
  city,
  state_id
FROM (
  SELECT DISTINCT city, s.state_id
  FROM sales_raw sr
  JOIN states s ON sr.state = s.state_name
) AS sub;

-- Optional: Clean up incorrect city entries
DELETE FROM cities WHERE city_id >= 1000;

-- Step 4: Create Fact Tables
CREATE TABLE orders (
  order_uid SERIAL PRIMARY KEY,
  order_id VARCHAR(50),
  order_date DATE NOT NULL,
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  city_id INT NOT NULL REFERENCES cities(city_id),
  payment_mode VARCHAR(50) NOT NULL
);

CREATE TABLE order_items (
  item_id SERIAL PRIMARY KEY,
  order_uid INT NOT NULL REFERENCES orders(order_uid),
  product_id INT NOT NULL REFERENCES products(product_id),
  quantity INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  profit DECIMAL(10,2) NOT NULL
);

-- Step 5: Populate Orders
INSERT INTO orders (order_date, customer_id, city_id, payment_mode)
SELECT DISTINCT 
  sr."Order Date", c.customer_id, ci.city_id, sr.paymentmode
FROM sales_raw sr
JOIN customers c ON sr.customername = c.customer_name
JOIN cities ci ON sr.city = ci.city_name;

-- Step 6: Populate Order Items
INSERT INTO order_items (order_uid, product_id, quantity, amount, profit)
SELECT
  o.order_uid, p.product_id, sr.quantity, sr.amount, sr.profit
FROM sales_raw sr
JOIN customers c ON sr.customername = c.customer_name
JOIN cities ci ON sr.city = ci.city_name
JOIN orders o ON
  sr."Order Date" = o.order_date AND
  c.customer_id = o.customer_id AND
  ci.city_id = o.city_id AND
  sr.paymentmode = o.payment_mode
JOIN products p ON
  sr.category = p.category AND
  sr."Sub-Category" = p.sub_category;

-- Step 7: Update Orders with Original Order ID
UPDATE orders o
SET order_id = sr."Order ID"
FROM sales_raw sr
JOIN customers c ON sr.customername = c.customer_name
JOIN cities ci ON sr.city = ci.city_name
WHERE o.customer_id = c.customer_id
  AND o.city_id = ci.city_id
  AND o.order_date = sr."Order Date";

-- Step 8: Validation Queries
SELECT COUNT(*) FROM order_items;
SELECT COUNT(DISTINCT order_id) FROM orders;
SELECT COUNT(DISTINCT "Order ID") FROM sales_raw;

-- Final Clean-Up
ALTER TABLE orders DROP COLUMN year_month;