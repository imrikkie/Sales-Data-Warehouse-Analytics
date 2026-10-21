-- Analysis: Part-to-Whole Sales Analysis
-- Objective:
--   1. Calculate total sales for each product category.
--   2. Calculate overall sales across all categories.
--   3. Determine each category's percentage contribution
--      to overall sales.

USE datawarehouseanalytics2;
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM fact_sales AS f
    LEFT JOIN dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    -- Total sales across all categories
    SUM(total_sales) OVER () AS overall_sales,
    -- Percentage contribution of each category
    ROUND(
        100.0 * total_sales / NULLIF(SUM(total_sales) OVER (), 0),
        2
    ) AS percentage_share

FROM category_sales
ORDER BY percentage_share DESC;