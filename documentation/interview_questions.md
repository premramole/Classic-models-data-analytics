# Interview Questions & Answers

## 1. SQL Questions
**Q: How do you find the total revenue per product line?**
**A:** I would join the `productlines`, `products`, and `orderdetails` tables. Then, I'd group by the product line name and sum the product of `quantityOrdered` and `priceEach`.
**Example from this project:** `SELECT p.productLine, SUM(od.quantityOrdered * od.priceEach) FROM products p JOIN orderdetails od ON p.productCode = od.productCode GROUP BY p.productLine;`

**Q: How do you identify customers with no assigned sales rep?**
**A:** I would query the customers table and filter where the foreign key for the sales representative is NULL.
**Example from this project:** `SELECT customerName FROM customers WHERE salesRepEmployeeNumber IS NULL;`

**Q: Explain a LEFT JOIN vs INNER JOIN in this dataset.**
**A:** An INNER JOIN returns only records that match in both tables. A LEFT JOIN returns all records from the left table, even if there are no matches in the right table.
**Example from this project:** Using a LEFT JOIN from `customers` to `orders` ensures we see all customers, even those who haven't placed an order yet.

**Q: How do you find the second highest order value?**
**A:** I would calculate total order values by grouping by order ID, order the results descending, and use `LIMIT 1 OFFSET 1`.
**Example from this project:** Grouping `orderdetails` by `orderNumber`, sorting by `SUM(quantityOrdered * priceEach) DESC LIMIT 1 OFFSET 1`.

**Q: How do you calculate a running total of payments?**
**A:** I would use a Window Function: `SUM(amount) OVER (ORDER BY paymentDate)`.
**Example from this project:** Useful for tracking cash flow over the 2003-2005 period.

**Q: How do you find duplicate records?**
**A:** I would group by the unique identifiers (or all columns) and use a `HAVING COUNT(*) > 1` clause.
**Example from this project:** `SELECT orderNumber, productCode, COUNT(*) FROM orderdetails GROUP BY orderNumber, productCode HAVING COUNT(*) > 1;`

**Q: What is the difference between WHERE and HAVING?**
**A:** WHERE filters rows before aggregation, while HAVING filters aggregated results after the GROUP BY clause.
**Example from this project:** Use WHERE for `status = 'Shipped'`, and HAVING for `SUM(revenue) > 10000`.

**Q: How do you optimize a slow query?**
**A:** I check the execution plan (EXPLAIN), ensure proper indexes exist on JOIN/WHERE columns, avoid SELECT *, and try to minimize subqueries.
**Example from this project:** Ensuring indexes exist on `customerNumber` and `productCode`.

## 2. Python/Pandas Questions
**Q: How do you handle missing values in Pandas?**
**A:** Depending on the context, I either drop them using `dropna()`, fill them with a mean/median/custom value using `fillna()`, or leave them if the nulls hold business meaning.
**Example from this project:** Address Line 2 nulls were left as-is, while unassigned sales reps were labeled 'Unassigned'.

**Q: How do you merge datasets in Pandas?**
**A:** I use `pd.merge()`, specifying the left and right dataframes, the type of join (how='left'/'inner'), and the key columns (on='id').
**Example from this project:** Merging `orders` and `orderdetails` on `orderNumber`.

**Q: How do you group data and calculate aggregate metrics?**
**A:** I use the `groupby()` method followed by an aggregation function like `sum()` or `agg()`.
**Example from this project:** `df.groupby('productLine')['revenue'].sum()`.

**Q: Explain loc vs iloc.**
**A:** `loc` is label-based indexing, while `iloc` is integer-position based indexing.
**Example from this project:** Selecting a customer by name index (`loc`) vs by row number (`iloc`).

**Q: How do you create derived columns in Pandas?**
**A:** I assign a new column directly by performing operations on existing columns.
**Example from this project:** `df['revenue'] = df['quantityOrdered'] * df['priceEach']`.

**Q: How do you export cleaned data?**
**A:** I use `df.to_csv()` with `index=False` to prevent the dataframe index from saving as a column.
**Example from this project:** Exporting cleaned tables to `data/cleaned/`.

## 3. Power BI Questions
**Q: What is a Star Schema and why use it?**
**A:** A Star Schema organizes data into central Fact tables (metrics/events) and surrounding Dimension tables (attributes). It drastically improves query performance and simplifies DAX logic compared to normalized transactional tables.
**Example from this project:** Separating `orderdetails` as a fact table and `customers`/`products` as dimensions.

**Q: Explain the difference between a Calculated Column and a Measure.**
**A:** A Calculated Column computes a value row-by-row during data refresh and stores it in the model. A Measure aggregates data on the fly based on filter context in the visual.
**Example from this project:** Total Revenue is a Measure (`SUMX`), not a static column.

**Q: What is CALCULATE in DAX?**
**A:** `CALCULATE` is the most powerful DAX function; it evaluates an expression in a modified filter context.
**Example from this project:** `CALCULATE([Total Orders], orders[status] = "Shipped")` overrides the default status filter.

**Q: Why do you need a separate Date Table?**
**A:** A dedicated Date Table enables Time Intelligence functions (YTD, previous month), ensures continuous dates even if sales are missing on certain days, and standardizes filtering across the model.
**Example from this project:** The `DimDate` table allows us to compare Month-over-Month revenue.

**Q: How do you handle many-to-many relationships?**
**A:** Ideally, I resolve them by introducing a bridge/junction table. If necessary, Power BI supports many-to-many natively, but it requires careful attention to cross-filter directions.
**Example from this project:** OrderDetails acts as a bridge between Orders and Products.

## 4. Excel Questions
**Q: VLOOKUP vs XLOOKUP/INDEX-MATCH?**
**A:** XLOOKUP and INDEX-MATCH are more robust than VLOOKUP; they can look up leftward, don't break when columns are inserted, and are often faster.
**Example from this project:** Looking up employee names based on `salesRepEmployeeNumber`.

**Q: What are Pivot Tables used for?**
**A:** Pivot Tables quickly summarize, group, and aggregate large datasets without formulas.
**Example from this project:** Creating a quick matrix of Revenue by Product Line and Year.

**Q: How do you identify duplicates in Excel?**
**A:** I use Conditional Formatting -> Highlight Cell Rules -> Duplicate Values, or use the Remove Duplicates tool under the Data tab.
**Example from this project:** Checking the `orderNumber` column for anomalies.

**Q: What is the purpose of conditional formatting?**
**A:** It visually highlights data trends, anomalies, or KPIs (like red for negative growth) automatically based on rules.
**Example from this project:** Highlighting canceled orders in a dataset.

## 5. Data Cleaning Questions
**Q: What steps do you take when first receiving a dataset?**
**A:** I review the data dictionary, check row/column counts, look for null values, verify data types, check for duplicates, and look at summary statistics for outliers.
**Example from this project:** Building the `data_quality_report.md`.

**Q: How do you handle outliers?**
**A:** I investigate to see if they are data entry errors or legitimate business anomalies. I might cap them, exclude them, or keep them depending on the analysis goal.
**Example from this project:** Very high credit limits were validated against the customer's purchase history.

**Q: Why do data types matter?**
**A:** Incorrect data types break calculations (e.g., text instead of numeric), prevent date parsing, and inflate storage costs.
**Example from this project:** Ensuring `orderDate` is a DATE type to allow time-series analysis.

**Q: What do you do if a key column has null values?**
**A:** If it's a primary key, the row might need to be dropped or the data re-extracted. If it's a foreign key, I might create a "Dummy/Unknown" dimension record.
**Example from this project:** Handling NULL `salesRepEmployeeNumber`.

## 6. Business Analysis Questions
**Q: How do you measure business performance in this dataset?**
**A:** By tracking KPIs like Total Revenue, Order Volume, Average Order Value (AOV), and customer retention/repeat purchase rate.
**Example from this project:** Built these exactly on the Power BI executive dashboard.

**Q: How do you identify concentration risk?**
**A:** I look at the Pareto principle (80/20 rule) by sorting customers or products by revenue descending and calculating their cumulative percentage of total sales.
**Example from this project:** Identified that "Classic Cars" dominate revenue.

**Q: What is churn and how would you define it here?**
**A:** Churn is when a customer stops buying. Here, it could be defined as a customer who hasn't placed an order in the last 12 months.
**Example from this project:** Comparing MAX(orderDate) per customer against the current dataset date.

**Q: How do you prioritize recommendations?**
**A:** By assessing the potential business impact (revenue gained/saved) vs the effort/cost to implement.
**Example from this project:** Assigning sales reps to unassigned customers is high impact, low effort.

**Q: Why is gross margin important?**
**A:** Revenue shows scale, but gross margin shows profitability. High revenue with negative margins is unsustainable.
**Example from this project:** Comparing MSRP vs buyPrice across product lines.

**Q: How do you present insights to non-technical stakeholders?**
**A:** I focus on the "So What?"—the business impact and actionable recommendations, keeping technical jargon to a minimum and using clear visuals.
**Example from this project:** The Business Insights document focuses on Evidence, Meaning, and Recommendation.

## 7. Project Questions
**Q: What was the most challenging part of this project?**
**A:** Translating the highly normalized relational database into a Star Schema optimized for Power BI reporting while ensuring metrics like Total Revenue matched across different grains.

**Q: If you had more time, what would you add?**
**A:** I would perform a deeper cohort analysis to track customer retention over time, and build a predictive model to forecast Q4 seasonal spikes.

**Q: Tell me about a time you found an unexpected insight.**
**A:** While analyzing sales reps, I found 14 customers with no assigned representative but who had credit limits. This highlighted a gap in the CRM process and a quick win for the sales team.
