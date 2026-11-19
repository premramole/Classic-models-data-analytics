-- ==============================================================================
-- File: 02_create_tables.sql
-- Description: Create all 8 tables for Classic Models with constraints
-- Date: 2026-09-10
-- ==============================================================================

USE classicmodels_analytics;

-- Drop tables in reverse order of dependencies to avoid FK constraint errors
DROP TABLE IF EXISTS orderdetails;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS productlines;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS offices;

-- 1. offices
CREATE TABLE offices (
  officeCode VARCHAR(10) PRIMARY KEY,
  city VARCHAR(50) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  addressLine1 VARCHAR(50) NOT NULL,
  addressLine2 VARCHAR(50) NULL,
  state VARCHAR(50) NULL,
  country VARCHAR(50) NOT NULL,
  postalCode VARCHAR(15) NOT NULL,
  territory VARCHAR(10) NOT NULL
);

-- 2. employees
CREATE TABLE employees (
  employeeNumber INT PRIMARY KEY,
  lastName VARCHAR(50) NOT NULL,
  firstName VARCHAR(50) NOT NULL,
  extension VARCHAR(10) NOT NULL,
  email VARCHAR(100) NOT NULL,
  officeCode VARCHAR(10) NOT NULL,
  reportsTo INT NULL,
  jobTitle VARCHAR(50) NOT NULL,
  FOREIGN KEY (officeCode) REFERENCES offices(officeCode),
  FOREIGN KEY (reportsTo) REFERENCES employees(employeeNumber)
);

-- 3. customers
CREATE TABLE customers (
  customerNumber INT PRIMARY KEY,
  customerName VARCHAR(100) NOT NULL,
  contactLastName VARCHAR(50) NOT NULL,
  contactFirstName VARCHAR(50) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  addressLine1 VARCHAR(50) NOT NULL,
  addressLine2 VARCHAR(50) NULL,
  city VARCHAR(50) NOT NULL,
  state VARCHAR(50) NULL,
  postalCode VARCHAR(15) NULL,
  country VARCHAR(50) NOT NULL,
  salesRepEmployeeNumber INT NULL,
  creditLimit DECIMAL(10,2) NULL,
  FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees(employeeNumber)
);

-- 4. payments
CREATE TABLE payments (
  customerNumber INT,
  checkNumber VARCHAR(50),
  paymentDate DATE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (customerNumber, checkNumber),
  FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

-- 5. orders
CREATE TABLE orders (
  orderNumber INT PRIMARY KEY,
  orderDate DATE NOT NULL,
  requiredDate DATE NOT NULL,
  shippedDate DATE NULL,
  status ENUM('Shipped','Cancelled','On Hold','In Process','Resolved','Disputed') NOT NULL,
  comments TEXT NULL,
  customerNumber INT NOT NULL,
  FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

-- 6. productlines
CREATE TABLE productlines (
  productLine VARCHAR(50) PRIMARY KEY,
  textDescription VARCHAR(4000) NULL,
  htmlDescription MEDIUMTEXT NULL,
  image MEDIUMBLOB NULL
);

-- 7. products
CREATE TABLE products (
  productCode VARCHAR(15) PRIMARY KEY,
  productName VARCHAR(70) NOT NULL,
  productLine VARCHAR(50) NOT NULL,
  productVendor VARCHAR(50) NOT NULL,
  productDescription TEXT NOT NULL,
  quantityInStock SMALLINT NOT NULL,
  buyPrice DECIMAL(10,2) NOT NULL,
  MSRP DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (productLine) REFERENCES productlines(productLine)
);

-- 8. orderdetails
CREATE TABLE orderdetails (
  orderNumber INT,
  productCode VARCHAR(15),
  quantityOrdered INT NOT NULL,
  priceEach DECIMAL(10,2) NOT NULL,
  orderLineNumber SMALLINT NOT NULL,
  PRIMARY KEY (orderNumber, productCode),
  FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber),
  FOREIGN KEY (productCode) REFERENCES products(productCode)
);
