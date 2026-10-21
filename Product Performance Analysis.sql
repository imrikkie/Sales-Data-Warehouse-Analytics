
-- Analysis: Product Performance Analysis
-- Objective:
--   1. Aggregate annual sales for each product.
--   2. Compare annual sales against the product's average sales
--      across the observed years.
--   3. Calculate year-over-year sales changes.
--   4. Classify performance relative to average sales and
--      previous-year sales.

USE datawarehouseanalytics2;
WITH yearly_product_sales AS (
    SELECT
        YEAR(s.order_date) AS order_year,
        p.product_key,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM fact_sales AS s
    LEFT JOIN dim_products AS p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY
        YEAR(s.order_date),
        p.product_key,
        p.product_name
),

product_performance AS (
    SELECT
        order_year,
        product_key,
        product_name,
        current_sales,

        -- Average annual sales across the observed years
        AVG(current_sales) OVER (
            PARTITION BY product_key
        ) AS avg_sales,

        -- Previous available year's sales
        LAG(current_sales) OVER (
            PARTITION BY product_key
            ORDER BY order_year
        ) AS previous_year_sales

    FROM yearly_product_sales
)

SELECT
    order_year,
    product_key,
    product_name,
    current_sales,
    ROUND(avg_sales, 2) AS avg_sales,

    -- Difference from the product's average annual sales
    ROUND(current_sales - avg_sales, 2) AS diff_factor,

    CASE
        WHEN current_sales > avg_sales THEN 'Above Average'
        WHEN current_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS average_performance,

    previous_year_sales,

    -- Absolute year-over-year sales change
    ROUND(current_sales - previous_year_sales, 2) AS yoy_sales_change,

    CASE
        WHEN previous_year_sales IS NULL THEN 'No Previous Data'
        WHEN current_sales > previous_year_sales THEN 'Increase'
        WHEN current_sales < previous_year_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS yoy_growth

FROM product_performance
ORDER BY
    product_name,
    order_year;