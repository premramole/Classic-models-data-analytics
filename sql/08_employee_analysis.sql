-- ==============================================================================
-- File: 08_employee_analysis.sql
-- Description: Employee and sales rep performance queries
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- 22. Sales rep performance — revenue generated per sales rep (join employees→customers→orders→orderdetails)
-- WHAT: Total revenue closed by each sales rep.
-- WHY: Primary metric for evaluating sales rep success.
SELECT 
  e.employeeNumber,
  CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name,
  SUM(od.quantityOrdered * od.priceEach) AS total_revenue_generated
FROM employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY e.employeeNumber, sales_rep_name
ORDER BY total_revenue_generated DESC;

-- 23. Number of customers handled by each sales rep
-- WHAT: Count of assigned customers per rep.
-- WHY: Evaluates workload and portfolio size for each sales rep.
SELECT 
  e.employeeNumber,
  CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name,
  COUNT(c.customerNumber) AS number_of_customers
FROM employees e
LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
WHERE e.jobTitle = 'Sales Rep'
GROUP BY e.employeeNumber, sales_rep_name
ORDER BY number_of_customers DESC;

-- 24. Top 5 performing sales reps by revenue
-- WHAT: The 5 sales reps who generated the most revenue.
-- WHY: Identifies top performers for bonuses/recognition.
SELECT 
  e.employeeNumber,
  CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name,
  SUM(od.quantityOrdered * od.priceEach) AS total_revenue_generated
FROM employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY e.employeeNumber, sales_rep_name
ORDER BY total_revenue_generated DESC
LIMIT 5;

-- 25. Customers not assigned to any sales rep (salesRepEmployeeNumber IS NULL)
-- WHAT: Customers without a dedicated sales rep.
-- WHY: These customers might need attention to boost sales.
SELECT 
  customerName,
  city,
  country
FROM customers
WHERE salesRepEmployeeNumber IS NULL;

-- 26. Revenue by office/territory
-- WHAT: Total revenue broken down by office location.
-- WHY: Assesses regional office performance.
SELECT 
  off.officeCode,
  off.city,
  off.territory,
  SUM(od.quantityOrdered * od.priceEach) AS office_revenue
FROM offices off
JOIN employees e ON off.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY off.officeCode, off.city, off.territory
ORDER BY office_revenue DESC;

-- 27. Sales rep performance vs their office average
-- WHAT: Compares each rep's revenue to the average revenue of reps in their office.
-- WHY: Evaluates individual performance relative to local market conditions.
WITH RepRevenue AS (
  SELECT 
    e.employeeNumber,
    CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name,
    e.officeCode,
    SUM(od.quantityOrdered * od.priceEach) AS rep_revenue
  FROM employees e
  JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  GROUP BY e.employeeNumber, sales_rep_name, e.officeCode
),
OfficeAvg AS (
  SELECT 
    officeCode,
    AVG(rep_revenue) AS office_avg_revenue
  FROM RepRevenue
  GROUP BY officeCode
)
SELECT 
  rr.sales_rep_name,
  rr.officeCode,
  rr.rep_revenue,
  oa.office_avg_revenue,
  (rr.rep_revenue - oa.office_avg_revenue) AS variance_from_avg
FROM RepRevenue rr
JOIN OfficeAvg oa ON rr.officeCode = oa.officeCode
ORDER BY rr.officeCode, variance_from_avg DESC;
