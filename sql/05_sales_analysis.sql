-- ==============================================================================
-- File: 05_sales_analysis.sql
-- Description: In-depth sales and revenue analysis queries
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- 8. Monthly revenue trend (year-month format, ordered chronologically)
-- WHAT: Shows revenue grouped by Year and Month.
-- WHY: To track monthly revenue performance over time.
SELECT 
  DATE_FORMAT(o.orderDate, '%Y-%m') AS year_month,
  SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY year_month
ORDER BY year_month;

-- 9. Top 10 products by revenue
-- WHAT: Identifies the 10 products generating the most revenue.
-- WHY: Highlights the most critical products for the business.
SELECT 
  p.productName,
  SUM(od.quantityOrdered * od.priceEach) AS total_revenue
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName
ORDER BY total_revenue DESC
LIMIT 10;

-- 10. Top 10 products by quantity sold
-- WHAT: Identifies the top 10 products by volume sold.
-- WHY: High volume doesn't always mean high revenue; useful for logistics.
SELECT 
  p.productName,
  SUM(od.quantityOrdered) AS total_quantity_sold
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- 11. Average Order Value (total revenue / number of orders)
-- WHAT: Calculates the average amount spent per order.
-- WHY: Key metric for measuring customer purchasing behavior.
SELECT 
  SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT o.orderNumber) AS average_order_value
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber;

-- 12. Revenue by country
-- WHAT: Aggregates revenue based on the customer's country.
-- WHY: To identify top geographical markets.
SELECT 
  c.country,
  SUM(od.quantityOrdered * od.priceEach) AS country_revenue
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.country
ORDER BY country_revenue DESC;

-- 13. Revenue by city
-- WHAT: Aggregates revenue based on the customer's city.
-- WHY: More granular geographical performance insight.
SELECT 
  c.city,
  c.country,
  SUM(od.quantityOrdered * od.priceEach) AS city_revenue
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.city, c.country
ORDER BY city_revenue DESC;

-- 14. Order status distribution (count and percentage)
-- WHAT: Shows count and percentage of orders in each status.
-- WHY: Helps evaluate order fulfillment efficiency.
SELECT 
  status,
  COUNT(*) AS order_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- 15. Best-performing product lines (revenue + quantity + number of orders)
-- WHAT: Comprehensive view of product line performance.
-- WHY: Helps determine which lines are most valuable overall.
SELECT 
  p.productLine,
  SUM(od.quantityOrdered * od.priceEach) AS total_revenue,
  SUM(od.quantityOrdered) AS total_quantity_sold,
  COUNT(DISTINCT o.orderNumber) AS total_orders
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p.productLine
ORDER BY total_revenue DESC;
