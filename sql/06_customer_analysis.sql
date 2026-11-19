-- ==============================================================================
-- File: 06_customer_analysis.sql
-- Description: Queries focused on customer behavior and value
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- 16. Top 10 customers by revenue (join orders + orderdetails + customers)
-- WHAT: Finds the 10 customers who spent the most money.
-- WHY: Identifies VIP clients.
SELECT 
  c.customerName,
  SUM(od.quantityOrdered * od.priceEach) AS total_spent
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY total_spent DESC
LIMIT 10;

-- 17. Customers with highest number of orders
-- WHAT: Finds the customers who place the most frequent orders.
-- WHY: Identifies highly engaged customers.
SELECT 
  c.customerName,
  COUNT(o.orderNumber) AS total_orders
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY total_orders DESC
LIMIT 10;

-- 18. Customers with no orders (LEFT JOIN trick)
-- WHAT: Identifies customers registered but who have never ordered.
-- WHY: Good targets for marketing or sales outreach.
SELECT 
  c.customerName,
  c.contactFirstName,
  c.contactLastName
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
WHERE o.orderNumber IS NULL;

-- 19. Revenue per customer
-- WHAT: Total historical revenue generated per customer.
-- WHY: Customer Lifetime Value (CLV) proxy.
SELECT 
  c.customerNumber,
  c.customerName,
  IFNULL(SUM(od.quantityOrdered * od.priceEach), 0) AS total_revenue
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY total_revenue DESC;

-- 20. Customer ranking by revenue (using RANK())
-- WHAT: Ranks customers strictly by revenue.
-- WHY: Helps segment customers into tiers (A/B/C).
SELECT 
  c.customerName,
  SUM(od.quantityOrdered * od.priceEach) AS total_revenue,
  RANK() OVER (ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS customer_rank
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName;

-- 21. Repeat customers (customers with more than 1 order)
-- WHAT: Counts customers with multiple orders.
-- WHY: Shows customer retention and loyalty.
SELECT 
  c.customerName,
  COUNT(o.orderNumber) AS order_count
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
HAVING COUNT(o.orderNumber) > 1
ORDER BY order_count DESC;
