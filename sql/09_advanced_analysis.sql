-- ==============================================================================
-- File: 09_advanced_analysis.sql
-- Description: Advanced analytics using CTEs, window functions, and subqueries
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- ==========================================
-- Query 1: RANK() — Customer revenue ranking
-- ==========================================
-- WHAT: Ranks customers based on their total historical spend.
-- WHY: A Data Analyst would use this to easily identify top tier clients.
-- OUTPUT: customerName, total_spend, customer_rank
SELECT 
  c.customerName,
  SUM(od.quantityOrdered * od.priceEach) AS total_spend,
  RANK() OVER (ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS customer_rank
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName;

-- =======================================================================
-- Query 2: DENSE_RANK() — Product revenue ranking within each product line
-- =======================================================================
-- WHAT: Ranks products by revenue within their specific product line category.
-- WHY: A Data Analyst uses this to find the top products per category without gaps in ranking.
-- OUTPUT: productLine, productName, product_revenue, rank_in_line
SELECT 
  p.productLine,
  p.productName,
  SUM(od.quantityOrdered * od.priceEach) AS product_revenue,
  DENSE_RANK() OVER (PARTITION BY p.productLine ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS rank_in_line
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.productLine;

-- =================================================================
-- Query 3: ROW_NUMBER() — Identify each customer's most recent order
-- =================================================================
-- WHAT: Finds the latest order details for every customer.
-- WHY: A Data Analyst uses this to see the most recent engagement of every client.
-- OUTPUT: customerName, orderNumber, orderDate
WITH RankedOrders AS (
  SELECT 
    c.customerName,
    o.orderNumber,
    o.orderDate,
    ROW_NUMBER() OVER (PARTITION BY c.customerNumber ORDER BY o.orderDate DESC) AS rn
  FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
)
SELECT customerName, orderNumber, orderDate
FROM RankedOrders
WHERE rn = 1;

-- ==================================================================================
-- Query 4: LAG() — Month-over-month revenue change (compare current month to prior month)
-- ==================================================================================
-- WHAT: Calculates monthly revenue and the difference from the previous month.
-- WHY: A Data Analyst uses this to evaluate growth trends and spot revenue dips.
-- OUTPUT: year_month, monthly_revenue, prev_month_revenue, revenue_change
WITH MonthlyRev AS (
  SELECT 
    DATE_FORMAT(o.orderDate, '%Y-%m') AS year_month,
    SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
  FROM orders o
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  GROUP BY year_month
)
SELECT 
  year_month,
  monthly_revenue,
  LAG(monthly_revenue) OVER (ORDER BY year_month) AS prev_month_revenue,
  monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year_month) AS revenue_change
FROM MonthlyRev;

-- ======================================================================
-- Query 5: Running total of revenue over time (ordered by year-month)
-- ======================================================================
-- WHAT: Calculates a cumulative sum of revenue over time.
-- WHY: A Data Analyst uses this to visualize the company's total cumulative growth.
-- OUTPUT: year_month, monthly_revenue, running_total
WITH MonthlyRev AS (
  SELECT 
    DATE_FORMAT(o.orderDate, '%Y-%m') AS year_month,
    SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
  FROM orders o
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  GROUP BY year_month
)
SELECT 
  year_month,
  monthly_revenue,
  SUM(monthly_revenue) OVER (ORDER BY year_month) AS running_total
FROM MonthlyRev;

-- =================================================
-- Query 6: CTE — Top performing sales rep per office
-- =================================================
-- WHAT: Identifies the single best sales rep by revenue in each office.
-- WHY: A Data Analyst uses this for regional awards and localized performance review.
-- OUTPUT: officeCode, city, sales_rep_name, rep_revenue
WITH RepRevenue AS (
  SELECT 
    off.officeCode,
    off.city,
    CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name,
    SUM(od.quantityOrdered * od.priceEach) AS rep_revenue
  FROM offices off
  JOIN employees e ON off.officeCode = e.officeCode
  JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  GROUP BY off.officeCode, off.city, e.employeeNumber, sales_rep_name
),
RankedReps AS (
  SELECT 
    officeCode,
    city,
    sales_rep_name,
    rep_revenue,
    ROW_NUMBER() OVER (PARTITION BY officeCode ORDER BY rep_revenue DESC) AS rn
  FROM RepRevenue
)
SELECT officeCode, city, sales_rep_name, rep_revenue
FROM RankedReps
WHERE rn = 1;

-- ===============================================================================
-- Query 7: Subquery — Customers whose total spend exceeds the average customer spend
-- ===============================================================================
-- WHAT: Finds all customers who have spent more than the average customer lifetime spend.
-- WHY: A Data Analyst uses this to identify above-average customers for loyalty programs.
-- OUTPUT: customerName, total_spend
SELECT 
  c.customerName,
  SUM(od.quantityOrdered * od.priceEach) AS total_spend
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName
HAVING SUM(od.quantityOrdered * od.priceEach) > (
  SELECT 
    SUM(quantityOrdered * priceEach) / COUNT(DISTINCT customerNumber)
  FROM orders 
  JOIN orderdetails USING (orderNumber)
)
ORDER BY total_spend DESC;

-- =================================================================================
-- Query 8: Window function — Each product's revenue as % of its product line revenue
-- =================================================================================
-- WHAT: Shows what percentage of a category's total revenue comes from a single product.
-- WHY: A Data Analyst uses this to see product dominance within its own category.
-- OUTPUT: productLine, productName, product_revenue, line_revenue, pct_of_line_revenue
WITH ProductRev AS (
  SELECT 
    p.productLine,
    p.productName,
    SUM(od.quantityOrdered * od.priceEach) AS product_revenue
  FROM products p
  JOIN orderdetails od ON p.productCode = od.productCode
  GROUP BY p.productCode, p.productName, p.productLine
)
SELECT 
  productLine,
  productName,
  product_revenue,
  SUM(product_revenue) OVER (PARTITION BY productLine) AS line_revenue,
  ROUND((product_revenue / SUM(product_revenue) OVER (PARTITION BY productLine)) * 100, 2) AS pct_of_line_revenue
FROM ProductRev
ORDER BY productLine, product_revenue DESC;

-- ===============================================================
-- Query 9: CTE — Monthly revenue with 3-month rolling average
-- ===============================================================
-- WHAT: Calculates monthly revenue and smooths out the trend with a 3-month average.
-- WHY: A Data Analyst uses this to smooth out monthly volatility and see clear trends.
-- OUTPUT: year_month, monthly_revenue, rolling_3_month_avg
WITH MonthlyRev AS (
  SELECT 
    DATE_FORMAT(o.orderDate, '%Y-%m') AS year_month,
    SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
  FROM orders o
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  GROUP BY year_month
)
SELECT 
  year_month,
  monthly_revenue,
  AVG(monthly_revenue) OVER (ORDER BY year_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_avg
FROM MonthlyRev;

-- =====================================================================================================
-- Query 10: CASE statement — Classify customers by spend tier (High >$50k, Medium $20k-$50k, Low <$20k)
-- =====================================================================================================
-- WHAT: Segments customers into High, Medium, and Low value tiers based on total spend.
-- WHY: A Data Analyst uses this for targeted marketing strategies based on customer value.
-- OUTPUT: customerName, total_spend, customer_tier
SELECT 
  c.customerName,
  SUM(od.quantityOrdered * od.priceEach) AS total_spend,
  CASE 
    WHEN SUM(od.quantityOrdered * od.priceEach) > 50000 THEN 'High'
    WHEN SUM(od.quantityOrdered * od.priceEach) BETWEEN 20000 AND 50000 THEN 'Medium'
    ELSE 'Low'
  END AS customer_tier
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY total_spend DESC;
