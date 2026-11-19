# Data Dictionary for Classic Models Data Analytics

## 1. Customers (`customers_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `customerNumber` | Integer | Unique identifier for the customer | PK | No | Original unnamed column renamed to customerNumber |
| `customerName` | String | Name of the customer company | | No | Trimmed whitespace |
| `contactLastName` | String | Last name of the primary contact | | No | Trimmed whitespace |
| `contactFirstName` | String | First name of the primary contact | | No | Trimmed whitespace |
| `phone` | String | Phone number of the customer | | No | Trimmed whitespace |
| `addressLine1` | String | Address line 1 | | No | Trimmed whitespace |
| `addressLine2` | String | Address line 2 (optional) | | Yes | NULLs replaced with empty strings |
| `city` | String | City | | No | Trimmed whitespace |
| `state` | String | State or province | | Yes | NULLs replaced with empty strings |
| `postalCode` | String | Postal or zip code | | Yes | NULLs replaced with empty strings |
| `country` | String | Country | | No | Trimmed whitespace |
| `salesRepEmployeeNumber` | Integer | Employee number of the assigned sales rep | FK | Yes | 0 if unassigned. FK to `employees.employeeNumber` |
| `creditLimit` | Float | Maximum credit line for the customer | | No | 0 is valid for inactive customers |
| `hasAssignedRep` | Boolean | True if the customer has an assigned sales rep | | No | Generated flag |
| `isActiveCustomer` | Boolean | True if creditLimit > 0 | | No | Generated flag |

## 2. Employees (`employees_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `employeeNumber` | Integer | Unique identifier for the employee | PK | No | |
| `lastName` | String | Last name of the employee | | No | Trimmed whitespace |
| `firstName` | String | First name of the employee | | No | Trimmed whitespace |
| `extension` | String | Phone extension | | No | Trimmed whitespace |
| `email` | String | Email address | | No | Trimmed whitespace |
| `officeCode` | String | Office code where employee works | FK | No | FK to `offices.officeCode`. Trimmed whitespace |
| `reportsTo` | Integer | Manager's employee number | FK | Yes | 0 for top of hierarchy (President). FK to `employees.employeeNumber` |
| `jobTitle` | String | Job title | | No | Trimmed whitespace |

## 3. Offices (`offices_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `officeCode` | String | Unique identifier for the office | PK | No | |
| `city` | String | City where office is located | | No | Trimmed whitespace |
| `phone` | String | Phone number | | No | Trimmed whitespace |
| `addressLine1` | String | Address line 1 | | No | Trimmed whitespace |
| `addressLine2` | String | Address line 2 (optional) | | Yes | NULLs replaced with empty strings |
| `state` | String | State or province | | Yes | NULLs replaced with empty strings |
| `country` | String | Country | | No | Trimmed whitespace |
| `postalCode` | String | Postal or zip code | | No | Trimmed whitespace |
| `territory` | String | Sales territory | | No | Trimmed whitespace |

## 4. Orders (`orders_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `orderNumber` | Integer | Unique identifier for the order | PK | No | |
| `orderDate` | Datetime | Date the order was placed | | No | Converted to datetime |
| `requiredDate` | Datetime | Date the order is required | | No | Converted to datetime |
| `shippedDate` | Datetime | Date the order shipped | | Yes | NaN for unshipped orders |
| `status` | String | Current status of the order | | No | Shipped, Cancelled, On Hold, In Process, Resolved, Disputed |
| `comments` | String | Comments on the order | | Yes | NULLs replaced with empty strings |
| `customerNumber` | Integer | Customer who placed the order | FK | No | FK to `customers.customerNumber` |
| `isShipped` | Boolean | True if order has been shipped | | No | Generated flag |
| `orderYear` | Integer | Year of orderDate | | No | Generated field |
| `orderMonth` | Integer | Month of orderDate | | No | Generated field |
| `daysToShip` | Float | Number of days between order and shipment | | Yes | NaN for unshipped orders |

## 5. OrderDetails (`orderdetails_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `orderNumber` | Integer | Order identifier | PK/FK | No | FK to `orders.orderNumber` |
| `productCode` | String | Product identifier | PK/FK | No | FK to `products.productCode` |
| `quantityOrdered` | Integer | Number of units ordered | | No | |
| `priceEach` | Float | Price per unit | | No | |
| `orderLineNumber` | Integer | Line number within the order | | No | |
| `lineRevenue` | Float | Total revenue for the line | | No | Generated (quantityOrdered * priceEach) |

## 6. Payments (`payments_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `customerNumber` | Integer | Customer identifier | PK/FK | No | FK to `customers.customerNumber` |
| `checkNumber` | String | Check identifier | PK | No | |
| `paymentDate` | Datetime | Date the payment was made | | No | Converted to datetime |
| `amount` | Float | Amount paid | | No | |
| `paymentYear` | Integer | Year of paymentDate | | No | Generated field |
| `paymentMonth` | Integer | Month of paymentDate | | No | Generated field |

## 7. ProductLines (`productlines_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `productLine` | String | Product line identifier | PK | No | Trimmed whitespace |
| `textDescription` | String | Description of the product line | | No | Trimmed whitespace |

## 8. Products (`products_clean.csv`)
| Column Name | Data Type | Description | PK/FK | Nullable | Notes |
|---|---|---|---|---|---|
| `productCode` | String | Unique product identifier | PK | No | |
| `productName` | String | Name of the product | | No | Trimmed whitespace |
| `productLine` | String | Product line identifier | FK | No | FK to `productlines.productLine`. Trimmed whitespace |
| `productVendor` | String | Vendor who supplies the product | | No | Trimmed whitespace |
| `productDescription` | String | Description of the product | | No | Trimmed whitespace |
| `quantityInStock` | Integer | Number of units currently in stock | | No | |
| `buyPrice` | Float | Price paid for the product | | No | |
| `MSRP` | Float | Manufacturer's suggested retail price | | No | |
| `grossMargin` | Float | Gross margin | | No | Generated (MSRP - buyPrice) |
| `grossMarginPct` | Float | Gross margin percentage | | No | Generated |
| `isLowStock` | Boolean | True if quantity in stock < 100 | | No | Generated flag |
