-- ===============================================================================
-- 01 - Exploratory Analysis and Business KPIs
-- Database: datawarehouseanalytics2 | MySQL 8.0+
-- ===============================================================================
USE datawarehouseanalytics2;

-- 1. Table and schema exploration
SHOW TABLES;
DESCRIBE fact_sales;
DESCRIBE dim_customers;
DESCRIBE dim_products;

-- 2. Date coverage and data quality
SELECT
    MIN(STR_TO_DATE(order_date, '%Y-%m-%d')) AS first_order_date,
    MAX(STR_TO_DATE(order_date, '%Y-%m-%d')) AS last_order_date,
    TIMESTAMPDIFF(
        MONTH,
        MIN(STR_TO_DATE(order_date, '%Y-%m-%d')),
        MAX(STR_TO_DATE(order_date, '%Y-%m-%d'))
    ) AS order_range_months,
    SUM(order_date IS NULL) AS null_order_dates,
    SUM(order_date IS NOT NULL
        AND STR_TO_DATE(order_date, '%Y-%m-%d') IS NULL) AS invalid_order_dates
FROM fact_sales;

-- 3. Core business KPIs
SELECT
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    AVG(price) AS average_price,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT product_key) AS products_sold,
    COUNT(DISTINCT customer_key) AS customers_with_orders
FROM fact_sales;

SELECT COUNT(DISTINCT product_key) AS total_products
FROM dim_products;

SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM dim_customers;

-- KPI summary
SELECT 'Total Sales' AS metric, SUM(sales_amount) AS metric_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION ALL
SELECT 'Products Sold', COUNT(DISTINCT product_key) FROM fact_sales
UNION ALL
SELECT 'Customers With Orders', COUNT(DISTINCT customer_key) FROM fact_sales;

-- 4. Customer distribution
SELECT country, COUNT(DISTINCT customer_key) AS total_customers
FROM dim_customers
GROUP BY country
ORDER BY total_customers DESC;

SELECT gender, COUNT(DISTINCT customer_key) AS total_customers
FROM dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- 5. Product distribution
SELECT category, COUNT(DISTINCT product_key) AS total_products
FROM dim_products
GROUP BY category
ORDER BY total_products DESC;

SELECT category, ROUND(AVG(cost), 2) AS average_cost
FROM dim_products
GROUP BY category
ORDER BY average_cost DESC;

SELECT DISTINCT category, subcategory, product_name
FROM dim_products
ORDER BY category, subcategory, product_name;
