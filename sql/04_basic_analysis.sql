-- ==============================================================================
-- File: 04_basic_analysis.sql
-- Description: Basic exploratory data analysis queries
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- 1. Total number of customers
-- WHAT: Counts all registered customers.
-- WHY: Provides a baseline of the customer base size.
SELECT COUNT(*) AS total_customers FROM customers;

-- 2. Total number of orders
-- WHAT: Counts all orders placed regardless of status.
-- WHY: Gives an idea of order volume.
SELECT COUNT(*) AS total_orders FROM orders;

-- 3. Total revenue 
-- WHAT: Sums quantity * priceEach from orderdetails.
-- WHY: Shows the total historical gross revenue.
SELECT SUM(quantityOrdered * priceEach) AS total_revenue FROM orderdetails;

-- 4. Total number of products
-- WHAT: Counts distinct products offered.
-- WHY: Baseline inventory metric.
SELECT COUNT(*) AS total_products FROM products;

-- 5. Sales (revenue) by year
-- WHAT: Aggregates revenue by the year the order was placed.
-- WHY: To understand year-over-year business growth.
SELECT 
  YEAR(o.orderDate) AS order_year,
  SUM(od.quantityOrdered * od.priceEach) AS yearly_revenue
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY order_year
ORDER BY order_year;

-- 6. Sales (revenue) by month (across all years)
-- WHAT: Aggregates revenue by month number (1-12).
-- WHY: Helps identify seasonality in sales.
SELECT 
  MONTH(o.orderDate) AS order_month,
  SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY order_month
ORDER BY order_month;

-- 7. Sales (revenue) by product line
-- WHAT: Aggregates revenue for each product line.
-- WHY: Determines which category of products brings in the most money.
SELECT 
  p.productLine,
  SUM(od.quantityOrdered * od.priceEach) AS product_line_revenue
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productLine
ORDER BY product_line_revenue DESC;
