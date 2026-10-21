/*
===============================================================================
 Customer and Product Reporting Views
Purpose:
  - Create reusable customer-level and product-level reporting views.
  - Expose customer segments, age groups, sales metrics and recency.
  - Expose product segments, sales metrics, lifespan and revenue KPIs.
===============================================================================
*/

USE datawarehouseanalytics2;
-- ---------------------------------------------------------------------------
-- 1. Customer report view
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW report_customers AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        STR_TO_DATE(f.order_date, '%Y-%m-%d') AS order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) AS age
    FROM fact_sales AS f
    LEFT JOIN dim_customers AS c
        ON c.customer_key = f.customer_key
    WHERE STR_TO_DATE(f.order_date, '%Y-%m-%d') IS NOT NULL
),
customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan_months
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE
        WHEN lifespan_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency_months,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan_months,
    ROUND(total_sales / NULLIF(total_orders, 0), 2) AS avg_order_value,
    ROUND(
        total_sales / NULLIF(lifespan_months, 0),
        2
    ) AS avg_monthly_spend
FROM customer_aggregation;


-- ---------------------------------------------------------------------------
-- 2. Product report view
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW report_products AS
WITH base_query AS (
    SELECT
        f.order_number,
        STR_TO_DATE(f.order_date, '%Y-%m-%d') AS order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM fact_sales AS f
    LEFT JOIN dim_products AS p
        ON f.product_key = p.product_key
    WHERE STR_TO_DATE(f.order_date, '%Y-%m-%d') IS NOT NULL
),
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        TIMESTAMPDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan_months,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(
            AVG(sales_amount / NULLIF(quantity, 0)),
            2
        ) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    TIMESTAMPDIFF(MONTH, last_sale_date, CURDATE()) AS recency_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan_months,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    ROUND(total_sales / NULLIF(total_orders, 0), 2) AS avg_order_revenue,
    ROUND(
        total_sales / NULLIF(lifespan_months, 0),
        2
    ) AS avg_monthly_revenue
FROM product_aggregations;