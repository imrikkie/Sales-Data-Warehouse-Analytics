-- Analysis: Annual Sales Trend Analysis
-- Approach: Subquery + Window Functions
-- Objective:
--   1. Calculate annual sales and average selling price.
--   2. Calculate cumulative sales across years.
--   3. Calculate a three-year moving average of annual prices.


USE datawarehouseanalytics2;

WITH yearly_sales AS (
    SELECT
        YEAR(STR_TO_DATE(order_date, '%Y-%m-%d')) AS order_year,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM fact_sales
    WHERE STR_TO_DATE(order_date, '%Y-%m-%d') IS NOT NULL
    GROUP BY YEAR(STR_TO_DATE(order_date, '%Y-%m-%d'))
)

SELECT
    order_year,
    total_sales,

    SUM(total_sales) OVER (
        ORDER BY order_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,

    AVG(avg_price) OVER (
        ORDER BY order_year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_price

FROM yearly_sales
ORDER BY order_year;
