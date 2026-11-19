-- ==============================================================================
-- File: 07_product_analysis.sql
-- Description: Queries focused on product performance, inventory, and margin
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- Top 10 products by revenue with product line
-- WHAT: Details top products including their category.
-- WHY: Contextualizes revenue leaders by product line.
SELECT 
  p.productName,
  p.productLine,
  SUM(od.quantityOrdered * od.priceEach) AS total_revenue
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.productLine
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 products by quantity sold
-- WHAT: Top products by raw unit volume.
-- WHY: Shows the most frequently moving inventory.
SELECT 
  p.productName,
  SUM(od.quantityOrdered) AS total_quantity_sold
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Revenue and quantity by product line
-- WHAT: Summary of sales by product line.
-- WHY: Shows which lines move volume vs which drive revenue.
SELECT 
  p.productLine,
  SUM(od.quantityOrdered * od.priceEach) AS total_revenue,
  SUM(od.quantityOrdered) AS total_quantity_sold
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY total_revenue DESC;

-- Products with low stock (quantityInStock < 100)
-- WHAT: Identifies products with inventory under 100 units.
-- WHY: Inventory re-ordering and stockout prevention alert.
SELECT 
  productCode,
  productName,
  quantityInStock
FROM products
WHERE quantityInStock < 100
ORDER BY quantityInStock ASC;

-- Most ordered products vs inventory (are popular products low on stock?)
-- WHAT: Compares high sales volume against current stock levels.
-- WHY: Helps prioritize restocks for bestsellers.
SELECT 
  p.productName,
  SUM(od.quantityOrdered) AS total_ordered,
  p.quantityInStock,
  (p.quantityInStock - SUM(od.quantityOrdered)) AS stock_balance_indicator
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.quantityInStock
ORDER BY total_ordered DESC
LIMIT 20;

-- Product gross margin analysis using (MSRP - buyPrice) / MSRP
-- WHAT: Calculates the theoretical gross margin % for each product.
-- WHY: Highlights the most profitable products.
SELECT 
  productName,
  buyPrice,
  MSRP,
  ROUND(((MSRP - buyPrice) / MSRP) * 100, 2) AS gross_margin_percentage
FROM products
ORDER BY gross_margin_percentage DESC;

-- Top 5 products by gross margin %
-- WHAT: The 5 products with the highest profit margins.
-- WHY: Marketing these can yield higher profits.
SELECT 
  productName,
  ROUND(((MSRP - buyPrice) / MSRP) * 100, 2) AS gross_margin_percentage
FROM products
ORDER BY gross_margin_percentage DESC
LIMIT 5;

-- Products that appear in the most orders
-- WHAT: Counts distinct orders each product appears in.
-- WHY: Indicates broad popularity across different purchases.
SELECT 
  p.productName,
  COUNT(DISTINCT od.orderNumber) AS times_ordered
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
ORDER BY times_ordered DESC;
