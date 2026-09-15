# 📊 Sales, Customer & Product Analytics using SQL

## 📌 Project Overview

This project is a SQL-based analytics solution designed to analyze sales,
customer behavior, and product performance.

I built this project by following a YouTube tutorial, implementing the
queries from scratch while learning SQL concepts and strengthening my
understanding of data analysis and business reporting using SQL.

The project covers:

- Sales trends analysis
- Running totals and window-based average calculations
- Product performance analysis
- Customer segmentation (VIP, Regular, New)
- Business metrics and reporting
- Customer and product performance analysis

## 🛠️ Tech Stack

- SQL Server (T-SQL)
- Dataset: Provided with the tutorial
- Data Model: Star schema consisting of:
  - `fact_sales`
  - `dim_products`
  - `dim_customers`

## 📂 Project Structure & Analysis

### 1. 📈 Sales Analysis

- Sales analysis by year and month
- Running total of sales
- Average price analysis
- Year-over-Year (YoY) performance comparison
- Time-based sales analysis

### 2. 📦 Product Analytics

- Yearly product performance analysis
- Product performance compared with average performance
- Previous-year sales comparison
- Product segmentation
- High-performing, mid-range, and low-performing products
- Created `gold.report_products` view with product-level business metrics

### 3. 👥 Customer Analytics

- Customer segmentation:
  - VIP
  - Regular
  - New
- Customer spending and purchasing behavior
- Customer-level business metrics:
  - Total orders
  - Total sales
  - Total quantity
  - Total products
  - Lifespan in months
  - Recency
  - Average Order Value (AOV)
  - Average Monthly Spend
- Created `gold.report_customers` view for customer-level reporting

## 📊 Key SQL Concepts Used

- Aggregations: `SUM()`, `AVG()`, `COUNT()`
- Window Functions: `LAG()`, `SUM() OVER()`, `AVG() OVER()`
- Common Table Expressions (CTEs)
- Conditional logic using `CASE WHEN`
- Joins between fact and dimension tables
- Views using `CREATE VIEW`
- Date functions for time-based analysis
- Customer and product segmentation

## 🎯 Key Learnings

- Writing analytical SQL queries to generate business insights
- Using window functions for running totals and Year-over-Year analysis
- Performing time-based sales analysis
- Creating customer and product segmentation using `CASE` logic
- Building reusable reporting views
- Calculating customer and product business metrics
- Understanding how SQL can support data-driven decision making

## 🚀 How to Run

1. Load the dataset into SQL Server.
2. Ensure the required tables are available:
   - `gold.fact_sales`
   - `gold.dim_products`
   - `gold.dim_customers`
3. Execute the SQL scripts in the appropriate order.
4. Create the reporting views:
   - `gold.report_customers`
   - `gold.report_products`
5. Query the created views to explore the results.

## 📝 Acknowledgment

This project was built while learning from a YouTube tutorial.
I re-implemented the SQL queries from scratch to strengthen my SQL
and data analytics skills and added structured documentation to
improve readability and understanding.
