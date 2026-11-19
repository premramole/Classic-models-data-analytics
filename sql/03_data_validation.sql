-- ==============================================================================
-- File: 03_data_validation.sql
-- Description: Data validation queries for imported tables
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- 1. Row counts for all 8 tables
SELECT 'offices' AS tableName, COUNT(*) AS rowCount FROM offices
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'productlines', COUNT(*) FROM productlines
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orderdetails', COUNT(*) FROM orderdetails;

-- 2. NULL counts for every nullable column in every table
-- Customers
SELECT 
  SUM(CASE WHEN addressLine2 IS NULL THEN 1 ELSE 0 END) AS customers_addressLine2_nulls,
  SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS customers_state_nulls,
  SUM(CASE WHEN postalCode IS NULL THEN 1 ELSE 0 END) AS customers_postalCode_nulls,
  SUM(CASE WHEN salesRepEmployeeNumber IS NULL THEN 1 ELSE 0 END) AS customers_salesRep_nulls,
  SUM(CASE WHEN creditLimit IS NULL THEN 1 ELSE 0 END) AS customers_creditLimit_nulls
FROM customers;

-- Employees
SELECT SUM(CASE WHEN reportsTo IS NULL THEN 1 ELSE 0 END) AS employees_reportsTo_nulls
FROM employees;

-- Offices
SELECT 
  SUM(CASE WHEN addressLine2 IS NULL THEN 1 ELSE 0 END) AS offices_addressLine2_nulls,
  SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS offices_state_nulls
FROM offices;

-- Orders
SELECT 
  SUM(CASE WHEN shippedDate IS NULL THEN 1 ELSE 0 END) AS orders_shippedDate_nulls,
  SUM(CASE WHEN comments IS NULL THEN 1 ELSE 0 END) AS orders_comments_nulls
FROM orders;

-- Productlines
SELECT 
  SUM(CASE WHEN textDescription IS NULL THEN 1 ELSE 0 END) AS productlines_textDescription_nulls,
  SUM(CASE WHEN htmlDescription IS NULL THEN 1 ELSE 0 END) AS productlines_htmlDescription_nulls,
  SUM(CASE WHEN image IS NULL THEN 1 ELSE 0 END) AS productlines_image_nulls
FROM productlines;

-- 3. Check for orphaned records (FK violations)
-- Example: orderdetails without a valid order
SELECT COUNT(*) AS orphaned_orderdetails FROM orderdetails od
LEFT JOIN orders o ON od.orderNumber = o.orderNumber
WHERE o.orderNumber IS NULL;

-- 4. Check for duplicate primary keys
-- Example: customers
SELECT customerNumber, COUNT(*) AS count
FROM customers
GROUP BY customerNumber
HAVING COUNT(*) > 1;

-- 5. Date range check on orders (min/max orderDate)
SELECT MIN(orderDate) AS first_order_date, MAX(orderDate) AS last_order_date
FROM orders;

-- 6. Revenue sanity check (sum of quantityOrdered * priceEach)
SELECT SUM(quantityOrdered * priceEach) AS total_calculated_revenue
FROM orderdetails;

-- 7. Customer credit limit distribution (count of 0, >0)
SELECT 
  CASE 
    WHEN creditLimit = 0 OR creditLimit IS NULL THEN 'No Credit'
    ELSE 'Has Credit' 
  END AS credit_status,
  COUNT(*) AS customer_count
FROM customers
GROUP BY credit_status;

-- 8. Order status distribution
SELECT status, COUNT(*) AS status_count
FROM orders
GROUP BY status
ORDER BY status_count DESC;

-- 9. Verify all salesRepEmployeeNumber in customers exist in employees
SELECT COUNT(*) AS orphaned_customers
FROM customers c
LEFT JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
WHERE c.salesRepEmployeeNumber IS NOT NULL AND e.employeeNumber IS NULL;

-- 10. Check products with critically low stock (<100 units)
SELECT productCode, productName, quantityInStock
FROM products
WHERE quantityInStock < 100
ORDER BY quantityInStock ASC;
