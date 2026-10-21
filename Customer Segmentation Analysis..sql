-- Analysis: Customer Segmentation
-- Objective:
--   1. Calculate each customer's purchasing period in months.
--   2. Calculate total spending per customer.
--   3. Segment customers into VIP, Regular, and New categories.
--   4. Summarize customer counts by segment.
-- Segmentation Criteria:
--   VIP:     Purchasing period >= 12 months AND spending > 5000
--   Regular: Purchasing period >= 12 months AND spending <= 5000

USE datawarehouseanalytics2;
WITH customer_metrics AS (
    SELECT
        customer_key,
        TIMESTAMPDIFF(
            MONTH,
            MIN(STR_TO_DATE(order_date, '%Y-%m-%d')),
            MAX(STR_TO_DATE(order_date, '%Y-%m-%d'))
        ) AS purchasing_period_months,
        SUM(sales_amount) AS total_spending
    FROM fact_sales
    WHERE STR_TO_DATE(order_date, '%Y-%m-%d') IS NOT NULL
    GROUP BY customer_key
),

customer_segments AS (
    SELECT
        customer_key,
        CASE
            WHEN purchasing_period_months >= 12
                 AND total_spending > 5000
                THEN 'VIP'
            WHEN purchasing_period_months >= 12
                 AND total_spending <= 5000
                THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_metrics
)

SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;