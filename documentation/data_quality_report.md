# Data Quality Report for Classic Models Data Analytics

## Executive Summary
This report summarizes the data quality assessment and data cleaning steps applied to the Classic Models e-commerce dataset. The raw data contained several missing values ('NULL' strings), some unstructured data, and required the generation of analytical flags and metrics to better support BI reporting. Overall, the data quality is solid with no major structural issues, duplicate records were not observed as a primary concern, and relationships between keys remain intact.

## Per-Table Analysis & Key Data Quality Findings

### 1. Customers
- **Findings**: The primary key column was unnamed in the raw dataset. `salesRepEmployeeNumber` contained ~14 NULLs indicating unassigned customers. `addressLine2`, `state`, and `postalCode` contained valid NULLs (as not all international addresses have states or second address lines). Some customers had a `creditLimit` of 0, which correctly implies inactive or prospective customers.
- **Cleaning Applied**:
  - Renamed the unnamed first column to `customerNumber`.
  - Converted the string 'NULL' to proper NaN/missing values.
  - Filled missing `salesRepEmployeeNumber` with `0` and added a boolean `hasAssignedRep` column.
  - Replaced missing `addressLine2`, `state`, and `postalCode` values with empty strings.
  - Created `isActiveCustomer` flag based on `creditLimit > 0`.
  - Trimmed whitespace from all string columns.

### 2. Employees
- **Findings**: The `reportsTo` column contained 1 NULL value for the President (who sits at the top of the hierarchy).
- **Cleaning Applied**:
  - Filled the missing `reportsTo` with `0` to indicate no manager.
  - Replaced string 'NULL' with missing value and trimmed string columns.

### 3. Offices
- **Findings**: Contains minor missing data for `addressLine2` and `state`.
- **Cleaning Applied**:
  - Filled missing `addressLine2` and `state` with empty strings.
  - Replaced string 'NULL' with missing value and trimmed string columns.

### 4. Orders
- **Findings**: `shippedDate` contained valid NULLs for orders with status "Cancelled", "On Hold", or "In Process". `comments` also contained many NULLs. Date columns were stored as strings.
- **Cleaning Applied**:
  - Parsed `orderDate`, `requiredDate`, and `shippedDate` into proper datetime objects.
  - Filled missing `comments` with empty strings.
  - Retained NULL in `shippedDate` as it holds analytical meaning, and introduced an `isShipped` boolean flag.
  - Generated new temporal features: `orderYear` and `orderMonth`.
  - Added `daysToShip` derived from the difference between `shippedDate` and `orderDate`.

### 5. OrderDetails
- **Findings**: Data quality was excellent, containing no missing values.
- **Cleaning Applied**:
  - Calculated and added a new column `lineRevenue` derived by multiplying `quantityOrdered` by `priceEach`.

### 6. Payments
- **Findings**: Excellent data quality, no missing values. Date columns were stored as strings.
- **Cleaning Applied**:
  - Parsed `paymentDate` to proper datetime format.
  - Generated new temporal features: `paymentYear` and `paymentMonth`.

### 7. ProductLines
- **Findings**: `htmlDescription` and `image` columns were 100% missing/null across all 7 records, providing no value for analysis.
- **Cleaning Applied**:
  - Dropped `htmlDescription` and `image` entirely.
  - Trimmed whitespace on remaining string columns.

### 8. Products
- **Findings**: Perfect completeness, no null values found. Noticed critically low stock on certain items (e.g., S24_2000 has 15 units).
- **Cleaning Applied**:
  - Calculated `grossMargin` (`MSRP` - `buyPrice`) and `grossMarginPct`.
  - Generated an `isLowStock` boolean flag indicating if `quantityInStock < 100`.
  - Trimmed whitespace from string columns.

## Limitations of the Dataset
- **Geographic Data**: Address formats are inconsistent as international addresses don't strictly adhere to US-based formats (states/postal codes).
- **Incomplete History**: The date fields span a specific time range. Any historical price changes for products are not tracked (only the current `buyPrice` and `MSRP` are available in `Products`).
- **Dropped Features**: Product Line images and HTML descriptions were entirely absent, meaning downstream BI tools won't be able to display rich graphics based on the product lines out-of-the-box.
