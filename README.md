# SQL Data Warehouse Analytics

## Overview

This project uses MySQL to explore a sales data warehouse and answer practical business questions about sales, customers, and products. I built the analysis around three tables: `fact_sales`, `dim_customers`, and `dim_products`.

The goal was to move from understanding the data to producing analyses that could support business reporting. The scripts cover data checks and baseline metrics, sales and product performance, customer and product segmentation, revenue contribution, time-based analysis, and reusable reporting views.

## Database

- **Database:** `datawarehouseanalytics2`
- **SQL dialect:** MySQL 8.0+
- **Main tables:** `fact_sales`, `dim_customers`, `dim_products`

The scripts assume these tables already exist in the database. They do not create or load the source tables.

## Project Files

| File | Purpose |
|---|---|
| `Exploratory Analysis.sql` | Inspects the tables, checks order-date quality, calculates baseline KPIs, and explores customer and product distributions. |
| `Sales and Product Performance Analysis.sql` | Examines revenue by category, top and bottom products, top customers, and quantity sold by customer country. |
| `Annual Sales Trend Analysis.sql` | Summarizes yearly sales and average price, then calculates cumulative sales and a three-year moving average of annual average price. |
| `Product Performance Analysis.sql` | Compares annual sales for each product with its average across observed years and its previous available year. |
| `Customer Segmentation Analysis.sql` | Groups customers into VIP, Regular, and New segments using purchasing-period and spending thresholds. |
| `Product Segmentation Analysis.sql` | Groups products into cost ranges and counts the products in each range. |
| `Part-to-Whole Sales Analysis.sql` | Calculates category sales and each category's percentage contribution to overall sales. |
| `customer_product_reports.sql` | Creates the `report_customers` and `report_products` views for reusable customer-level and product-level reporting. |

## What the Analysis Covers

### Data exploration and quality

The exploratory script checks the database structure, reviews the coverage of order dates, identifies null or unparseable dates, and calculates baseline measures such as total sales, quantity, average price, orders, products sold, and customers with orders. It also examines customer distributions by country and gender and product distributions by category.

### Sales and product performance

The performance queries look at revenue by category, the highest- and lowest-revenue products, the customers contributing the most revenue, and quantity sold by customer country. The product-level time analysis compares each product's annual sales with its average across the years present in the data and with its previous available annual observation.

### Customer and product segmentation

Customer segments are based on the observed span between a customer's first and last valid order date and their total spending:

- **VIP:** purchasing period of at least 12 months and spending above 5,000.
- **Regular:** purchasing period of at least 12 months and spending of 5,000 or less.
- **New:** all other customers in this rule set.

Here, “New” means the observed purchasing history spans less than 12 months; it does not necessarily mean the customer recently joined or made their first purchase.

Product segmentation groups products by cost using the ranges defined in the SQL script. These are cost bands, not sales-performance tiers.

### Revenue contribution and trends

The part-to-whole analysis calculates each product category's share of total sales. The annual trend analysis calculates yearly sales, cumulative sales across years, and a moving average based on annual average price.

### Reporting views

The reporting script creates two views:

- `report_customers` includes customer details, age groups, segment labels, order and sales measures, last-order recency, average order value, and average monthly spend.
- `report_products` includes product details, cost, sales-based performance labels, order and customer counts, sales and quantity measures, last-sale recency, average selling price, average order revenue, and average monthly revenue.

The monthly average metrics use `NULLIF` to avoid division by zero. If a customer's or product's observed lifespan is zero months, the corresponding monthly average can be `NULL`.

## SQL Techniques Used

The project uses:

- Aggregate functions such as `SUM`, `AVG`, `COUNT`, `MIN`, and `MAX`
- Joins across fact and dimension tables
- Common table expressions (CTEs)
- `CASE` expressions for segmentation
- Date parsing with `STR_TO_DATE`
- Date calculations with `TIMESTAMPDIFF`
- Window functions, including `SUM() OVER`, `AVG() OVER`, and `LAG`
- Views for reusable reporting queries

## How to Run

1. Open MySQL Workbench or another MySQL 8.0-compatible SQL client.
2. Connect to the server containing the source tables.
3. Run the scripts against the `datawarehouseanalytics2` database.
4. Start with `Exploratory Analysis.sql` to understand the tables and check date quality.
5. Run the remaining analysis scripts as needed.
6. Run `customer_product_reports.sql` to create the reporting views, then query them.

For example:

```sql
USE datawarehouseanalytics2;

SELECT *
FROM report_customers
LIMIT 10;

SELECT *
FROM report_products
LIMIT 10;
```

Run the reporting script after confirming that the source tables and required columns are available.

## Notes and Assumptions

- The scripts expect the source tables to be present; data loading and warehouse construction are outside the scope of this repository.
- The SQL uses MySQL 8.0 features, including common table expressions and window functions.
- Date parsing assumes `order_date` is stored as text in `YYYY-MM-DD` format. Queries that explicitly parse dates exclude values that cannot be parsed.
- Thresholds used for customer and product segmentation are rule-based choices in the SQL, not statistically derived classifications.
- Results depend on the data currently loaded in the database. Validate query outputs against the source data before using them for business decisions.

## Closing

This project was a practical way for me to strengthen my SQL skills while looking at a sales dataset from several angles: data quality, business metrics, performance over time, segmentation, and reporting. I kept the analyses in separate scripts so each one has a clear purpose and can be run or reviewed independently.
