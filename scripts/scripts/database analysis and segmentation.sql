-- Analysis sales over time
SELECT 
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(sales_amount) as total_sales,
COUNT (DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL 
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date)

-- Calculate the total sales per month
-- and the running total of sales and moving average over time

SELECT 
order_date,
total_sales ,
SUM(total_sales) OVER(ORDER BY order_date) as running_total_sales,
avg_price,
AVG(avg_price) OVER(ORDER BY order_date) as moving_average
FROM
(
SELECT
DATETRUNC (month,order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC (month,order_date)
) t 

/*  Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and then previous year's sales */
WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_products] p
ON p.product_key=f.product_key
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date),
p.product_name
) 

SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales -AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales -AVG(current_sales) OVER(PARTITION BY product_name)  > 0 THEN 'Above Avg'
	 WHEN current_sales -AVG(current_sales) OVER(PARTITION BY product_name)  < 0 THEN 'Below Avg'
	 ELSE 'avg'
END avg_change,
-- year over year analysis
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales -LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_with_py,
CASE WHEN current_sales -LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)   > 0 THEN 'Increase'
	 WHEN current_sales -LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)   < 0 THEN 'Decrease'
	 ELSE 'avg'
END py_change
FROM yearly_product_sales
ORDER BY product_name,order_year

-- Which category contribute the more to overall sales?
SELECT 
total_sales,
category,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND(CAST (total_sales AS FLOAT)*100/SUM(total_sales) OVER() ,2),'%') AS percentage_of_total
FROM(
SELECT
category,
SUM(sales_amount) AS total_sales
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_products] p
ON p.product_key=f.product_key
GROUP BY category
) t
ORDER BY percentage_of_total DESC

-- SEGMENTATION OF PRODUCTS

/* Segment products into cost ranges and 
count how many products fall into each segment */
WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM [gold.dim_products]
)

SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products

-- CUSTOMER SEGMENTATION
/* Group customers into three segments based on their spending behaviour:
	-VIP : Customers with atleast 12 months of history and spending more than 5000
	- Regular: Customers with atleast 12 months of history and spending less than or equal to  5000 
	- New : Customers with a lifespan of less than 12 months 
And find the total number of customers by each group */
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month ,  MIN(order_date),MAX(order_date) ) AS lifespan
FROM [gold.dim_customers] c
lEFT JOIN [gold.fact_sales] f
ON c.customer_key=f.customer_key
GROUP BY c.customer_key
) 

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM(
SELECT 
customer_key,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment
FROM customer_spending
) t
GROUP BY customer_segment 
ORDER BY total_customers DESC
