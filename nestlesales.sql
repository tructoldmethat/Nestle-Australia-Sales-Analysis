-- Create a temporary table to pre-process data and use the processed data across multiple queries
DROP TEMPORARY TABLE IF EXISTS nestle_temp
CREATE TEMPORARY TABLE nestle_temp AS
WITH processed_data AS (
    SELECT sales_id
        , date
        , product_name
        , CAST(REPLACE(total_revenue,'$','') AS DECIMAL(10,2)) AS total_revenue 
        , sales_location
        , sales_medium
        , CAST(sales_count AS DECIMAL) AS sales_count
        , CAST(product_count AS DECIMAL) AS product_count
        , EXTRACT(YEAR FROM STR_TO_DATE(date,'%d-%b-%y')) AS year
        , EXTRACT(MONTH FROM STR_TO_DATE(date,'%d-%b-%y')) AS month
    FROM db.nestle
)
SELECT * FROM processed_data;

-- SEASONALITY --
-- Sales trend by year
SELECT DISTINCT year
    , SUM(total_revenue) AS revenue_by_year
    , SUM(sales_count) AS sales_by_year
FROM nestle_temp
GROUP BY year
ORDER BY year;

-- Sales trend by month
SELECT DISTINCT month
    , SUM(total_revenue) AS revenue_by_month
    , SUM(sales_count) AS sales_by_month
FROM nestle_temp
GROUP BY month
ORDER BY month;

-- DIMENSIONAL SEGMENTATION --
-- Total revenue and sales by product
SELECT DISTINCT product_name
    , SUM(total_revenue) AS revenue_by_product
    , SUM(sales_count) AS sales_by_product
FROM nestle_temp
GROUP BY product_name
ORDER BY revenue_by_product DESC;

-- Total revenue and sales by state
SELECT DISTINCT sales_location
	, SUM(total_revenue) AS revenue_by_location
    , SUM(sales_count) AS sales_by_location
FROM nestle_temp
GROUP BY sales_location
ORDER BY revenue_by_location DESC;

-- Total revenue and sales by sales medium
SELECT DISTINCT sales_medium
	, SUM(total_revenue) AS revenue_by_medium
    , SUM(sales_count) AS sales_by_medium
FROM nestle_temp
GROUP BY sales_medium
ORDER BY revenue_by_medium DESC;

-- SUMMARY STATS--
-- Count of product, total, minimum and maximum revenue of Nestlé from 2018 to 2020
SELECT COUNT(DISTINCT product_name) AS product_count
, SUM(sales_count) AS total_sales
, SUM(total_revenue) AS total_revenue
, MIN(total_revenue) AS min_revenue
, MAX(total_revenue) AS max_revenue
FROM nestle_temp

-- Average, minimum and maximum revenue by product
SELECT product_name
, ROUND(AVG(total_revenue),2) AS avg_revenue
, MIN(total_revenue) AS min_revenue
, MAX(total_revenue) AS max_revenue
FROM nestle_temp
GROUP BY product_name
ORDER BY avg_revenue DESC;

-- DISTRIBUTION --
-- Top 10 products with the highest sales
SELECT DISTINCT product_name
    , SUM(total_revenue) AS revenue_by_product
	, SUM(sales_count) AS sales_by_product
FROM nestle_temp
GROUP BY product_name
ORDER BY sales_by_product DESC
LIMIT 10;

-- Top 10 locations with the highest sales percentage
SELECT DISTINCT sales_location
	, SUM(total_revenue) AS revenue_by_location
    , SUM(sales_count) AS sales_by_location
FROM nestle_temp
GROUP BY sales_location
ORDER BY sales_by_location DESC
LIMIT 10;