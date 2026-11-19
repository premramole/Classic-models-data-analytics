# Project Explanation Guide (Interview Prep)

## 30-Second Version (The Elevator Pitch)
"For my recent portfolio project, I performed an end-to-end analysis of an E-commerce company using the ClassicModels database. I extracted and cleaned the data using SQL and Python, designed a Star Schema, and built an interactive Power BI dashboard. My analysis uncovered heavy revenue concentration in one product line and identified unassigned sales leads, resulting in actionable recommendations for sales territory realignment."

## 2-Minute Version (Structured Approach)
**Problem/Context:** 
"I analyzed the ClassicModels dataset, representing an e-commerce operation, to understand revenue drivers, operational bottlenecks, and sales performance."

**Data & Tools:** 
"The dataset contained over 300 orders and 120 customers. I used SQL for initial extraction and sanity checks, Python/Pandas to clean nulls and standardize formats, and Power BI for the final visualization."

**Analysis Steps:** 
"First, I assessed data quality, noting anomalies like unassigned sales reps and canceled orders. I then transformed the normalized tables into a Star Schema to optimize my Power BI model, creating a dedicated Date table and writing DAX for key metrics like Average Order Value and MoM Growth."

**Insights & Outcome:** 
"The analysis revealed three critical things: a severe reliance on the 'Classic Cars' product line, high Q4 seasonality, and a gap in lead management where 14 active customers had no sales rep. I documented these in a business insights report with actionable steps, demonstrating my ability to turn raw data into strategic business value."

## 5-Minute Detailed Version (The Deep Dive)
**1. Business Context & Problem Statement:**
"I built an end-to-end analytics solution for a fictional e-commerce retailer (ClassicModels). The goal was to provide the executive team with visibility into sales performance, product inventory risks, and regional customer distribution."

**2. Data Understanding & Extraction:**
"I started with 8 relational tables (Customers, Orders, OrderDetails, Products, etc.). I wrote a data dictionary to map the schema and used SQL to explore relationships. For instance, I had to join Orders, OrderDetails, and Products just to calculate line-item revenue (Quantity * PriceEach)."

**3. Data Cleaning (Python/Pandas):**
"I exported the raw data and used Pandas for quality checks. I found that the `htmlDescription` and `image` columns were completely null, so I dropped them to save space. I also handled address nulls and documented that 14 customers were missing sales rep assignments—a key business finding, not just a data error."

**4. Data Modeling (Power BI):**
"I imported the cleaned CSVs into Power BI. Instead of leaving it normalized, I designed a Star Schema. I made OrderDetails my primary fact table and linked it to DimCustomer, DimProduct, and DimEmployee. I also created a DAX Date table to enable time-intelligence functions like Month-over-Month revenue growth."

**5. DAX & Dashboard Design:**
"I wrote over 10 DAX measures, carefully using `CALCULATE`, `SUMX`, and `DIVIDE` to ensure accurate context transitions. The dashboard has three pages: an Executive Overview for high-level KPIs, a Product page for margin and volume analysis, and a Customer/Regional page tracking sales rep performance."

**6. Key Insights:**
"The final insights were impactful. 
First, the Pareto principle was in full effect: 'Classic Cars' drove the vast majority of revenue, presenting a diversification risk. 
Second, the 14 'orphan' customers represented unmanaged revenue potential. 
Third, I quantified the revenue lost to 'Cancelled' and 'On Hold' orders, suggesting a need for operational review in fulfillment."

**7. Conclusion & Learnings:**
"This project solidified my full-stack analyst skills. I learned how crucial data modeling is before building dashboards—getting the Star Schema right made the DAX much easier and the dashboard much faster."

## Common Follow-up Questions

**Q: Why didn't you calculate Net Profit?**
*How to answer:* "I noticed the dataset only contained MSRP and `buyPrice` (wholesale cost) at the product level, but lacked transaction-level costs like shipping, discounts, or overhead. I calculated Gross Margin at the product level instead, to ensure I didn't present misleading profit numbers."

**Q: How did you handle the unassigned customers in Power BI?**
*How to answer:* "I left the foreign key as null in the cleaned data, and in Power BI, it defaults to a blank/null dimension. For the business report, I explicitly highlighted this as a failure in the CRM/Sales process rather than just dropping the data."

## What to Emphasize based on the Role
- **SQL-Heavy Role:** Focus on the complex joins, aggregations, window functions, and how you traced revenue through 4 different tables.
- **Python/Pandas Role:** Focus on your programmatic data quality checks, handling missing values, and generating the clean CSVs via scripts.
- **Power BI / Dataviz Role:** Focus heavily on the Star Schema design, DAX measures (like SUMX vs SUM), filter contexts, and UI/UX design choices in the dashboard.
