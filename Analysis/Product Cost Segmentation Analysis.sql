-- Analysis: Product Segmentation Analysis
-- Objective:
--   1. Categorize products into cost-based segments.
--   2. Count the number of products in each segment.

USE datawarehouseanalytics2;
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost < 500 THEN '100-499.99'
            WHEN cost <= 1000 THEN '500-1000'
            WHEN cost > 1000 THEN 'Above 1000'
            ELSE 'Unknown'
        END AS cost_range
    FROM dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;