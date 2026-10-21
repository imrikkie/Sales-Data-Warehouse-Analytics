/*
===============================================================================
Sales and Product Performance Analysis
===============================================================================
*/
USE datawarehouseanalytics2;

-- 1. Revenue by category
SELECT p.category, SUM(f.sales_amount) AS total_sales
FROM fact_sales AS f
LEFT JOIN dim_products AS p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;

-- 2. Top 5 products by revenue
SELECT p.product_key, p.product_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales AS f
LEFT JOIN dim_products AS p ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 3. Bottom 5 products by revenue
SELECT p.product_key, p.product_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales AS f
LEFT JOIN dim_products AS p ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name
ORDER BY total_revenue ASC
LIMIT 5;

-- 4. Top 10 customers by revenue
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales AS f
LEFT JOIN dim_customers AS c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 5. Quantity sold by customer country
SELECT c.country, SUM(f.quantity) AS total_quantity_sold
FROM fact_sales AS f
LEFT JOIN dim_customers AS c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_quantity_sold DESC;
