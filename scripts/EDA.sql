/************************************** DatabASe Exploration *******************************************************************
-- INFORMATION_SCHEMA.TABLES - To see all tables
-- INFORMATION_SCHEMA.COLUMNS - To see the list of columns FROM all tables
-
******************************************************************************************************************************/
--Explore all objects in the databASe
SELECT * FROM INFORMATION_SCHEMA.TABLES

--Explore all columns in the databASe
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'

/************************************** Dimensions Exploration *******************************************************************
-- Categories - 
-- Subcategories - 
-- This explorations will let us know how the data is categorised in the tables
*********************************************************************************************************************************/
-- Dimensions Exploration
--Explore all COUNTries our customer come FROM

SELECT DISTINCT country FROM gold.dim_customers

SELECT DISTINCT category,subcategory,product_name FROM gold.dim_products
ORDER BY 1,2,3

--Date exploration
SELECT MIN(ORDER_DATE) AS earliest_date,
MAX(ORDER_DATE) AS latest_date, DATEDIFF(YEAR,MIN(ORDER_DATE),MAX(ORDER_DATE)) AS timespan
FROM gold.fact_sales

SELECT * 
FROM gold.dim_customers

SELECT customer_key,first_name,lASt_name,birthdate
FROM gold.dim_customers
WHERE birthdate = (
	SELECT min(birthdate)
	FROM gold.dim_customers
)
union
SELECT customer_key,first_name,lASt_name,birthdate
FROM gold.dim_customers
WHERE birthdate = (
	SELECT MAX(birthdate)
	FROM gold.dim_customers
)

SELECT TOP 1 customer_key,first_name,lASt_name,birthdate
FROM gold.dim_customers
ORDER BY birthdate desc


/************************************** measures Exploration *******************************************************************
-- This explorations is used for aggregation such AS  
Total Sales	29356250
Total Quantity	60423
Average Selling Price	486
Total No. Of ORDERs	27659
Total Products	295
Total Customers	18484
Total Customers Place an ORDER	18482
*********************************************************************************************************************************/
--measures exploration
--Find the total sales
SELECT SUM(sales_amount) total_sales FROM gold.fact_sales

--Find how many items are sold
SELECT SUM(quantity) total_quantity FROM gold.fact_sales

--Find the average selling price
SELECT AVG(price) AS average_selling_price FROM gold.fact_sales


--Find the Total number of ORDERs
SELECT COUNT(ORDER_number) AS Total_No_ORDERs FROM gold.fact_sales
SELECT COUNT(DISTINCT ORDER_number) AS Total_No_ORDERs FROM gold.fact_sales

--Find the total number of Products
SELECT COUNT(DISTINCT product_key) AS Total_Customers FROM gold.dim_products

--Find the total number of Customers
SELECT COUNT(DISTINCT customer_key) AS Total_Customers FROM gold.dim_customers


--Find the total number of customers that hAS placed an ORDER
SELECT COUNT(DISTINCT customer_key) AS Total_Customers_placed_ORDER FROM gold.fact_sales
where ORDER_date is not null

--Generate a Report that show all key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) total_quantity FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS measure_name, AVG(price) AS average_selling_price FROM gold.fact_sales
UNION ALL
SELECT 'Total No. Of ORDERs' AS measure_name,COUNT(DISTINCT ORDER_number) AS Total_No_ORDERs FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(DISTINCT product_key) AS Total_Products FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(DISTINCT customer_key) AS Total_Customers FROM gold.dim_customers
UNION ALL
SELECT 'Total Customers Place an ORDER' AS measure_name, COUNT(DISTINCT customer_key) AS Total_Customers_placed_ORDER FROM gold.fact_sales
where ORDER_date is not null

/************************************** Magnitude Analysis *******************************************************************
-- 
-- Compare the measure values BY Categories
-- It helps us understand the importance of different Categories
-- measure BY Dimension
						Total sales BY country
						Total Quantity BY Category
						Average Price BY Product

				SELECT * FROM information_schema.COLUMNS

-- LOW CARDINALITY DIMENSTIONS - When there are only few categories/dimensions such AS Gender = Male, Female
-- HIGH CARDINALITY DIMENSTIONS - When there are only few categories/dimensions such AS Customers.......
*********************************************************************************************************************************/

SELECT * FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'gold'

-- Find total customer BY COUNTries
SELECT country,COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find total customers BY gender
SELECT gender,COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Find total products BY category
SELECT category,COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- What is the average costs in each category?
SELECT category,AVG(product_cost) AS average_costs
FROM gold.dim_products
GROUP BY category
ORDER BY average_costs DESC

-- What is the total revenue generated BY each customer

SELECT fs.customer_key,SUM(fs.sales_amount) AS total_revenue,cu.customer_number
FROM gold.fact_sales fs
left join gold.dim_customers cu
ON fs.customer_key = cu.customer_key
GROUP BY fs.customer_key,cu.customer_number
ORDER BY SUM(fs.sales_amount) DESC

-- What is the distribution of sold items across COUNTries?

SELECT cu.country,
SUM(fs.quantity) AS total_sold_items
FROM gold.fact_sales fs
left join gold.dim_customers cu
ON fs.customer_key = cu.customer_key
GROUP BY cu.country
ORDER BY total_sold_items DESC

/************************************** Ranking Analysis *******************************************************************
-- 
-- ORDER the values of dimensions BY measures
-- Top N Performers | Bottom N performers
-- Ranking BY aggregated measures
						Total 5 BY Quantity
						Bottom 3 customers BY quantity

				SELECT * FROM information_schema.COLUMNS

-- LOW CARDINALITY DIMENSTIONS - When there are only few categories/dimensions such AS Gender = Male, Female
-- HIGH CARDINALITY DIMENSTIONS - When there are only few categories/dimensions such AS Customers.......
*********************************************************************************************************************************/

SELECT * FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'gold'

-- Which 5 products generate the highest revenue?
SELECT TOP 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
left join gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

SELECT *
 FROM (
	SELECT
	p.product_name,
	SUM(f.sales_amount) total_revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS Rank_products
	FROM gold.fact_sales f
	left join gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name)t
WHERE Rank_products <= 5



-- What are the 5 worst-performing products in terms of sales?

SELECT TOP 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue

