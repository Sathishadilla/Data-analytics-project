/*
=======================================================================
Customer Report
========================================================================
Purpose:
	- This report consolidates key customer metrics and behaviours

Highlights:
	1. Gathers essential fields such as names , ages and transaction details.
	2. Segments csutomers into categories (VIP ,Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		-lifespan ( in months)
	4. Calculates valuable KPIs:
		- recency(months since last order)
		- average order value
		- average monthly spend

================================================================================
*/





CREATE VIEW gold.report_customers AS
WITH base_query AS (
/*------------------------------------------------------------------------------------
1. Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------------------*/

SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ' , c.last_name) AS  customer_name,
DATEDIFF (year,c.birthdate,GETDATE()) age
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c
ON c.customer_key=f.customer_key
WHERE order_date IS NOT NULL
)

, customer_aggregation AS(
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
	DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
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
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 20 AND 29 THEN '30-39'
	 WHEN age BETWEEN 20 AND 29 THEN '40-49'
	 ELSE '50 and Above'
END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment,
last_order_date,
DATEDIFF(month,last_order_date,GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Compute average order value
CASE WHEN total_sales=0 THEN 0
	 ELSE total_sales/total_orders
END AS avg_order_value,

-- Compute Average monthly spend
CASE WHEN lifespan=0 THEN total_sales
	 ELSE total_sales/lifespan
END AS avg_monthly_spend
FROM customer_aggregation


SELECT * FROM  gold.report_customers


/*
=====================================================================================
Product Report
======================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours.

Highlights:
	1. Gathers essential fields such as product name, category , subcategory, and cost.
	2. Segments products by revemue to identify High-Performers , Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers(unique)
		- lifespan ( in months)
	4. Calculates valuable KPIs:
		- recency(months since last order)
		- average order value (AOR)
		- average monthly Revenue

*/
  
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
    SELECT
	    f.order_number,
        f.order_date,
		f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM [gold.fact_sales] f
    LEFT JOIN [gold.dim_products] p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  -- only consider valid sales dates
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query

GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations 
