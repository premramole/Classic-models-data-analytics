# Power BI Dashboard — Complete Build Guide
# Classic Models E-Commerce Sales & Customer Analytics
# Dataset: ClassicModels (Standard MySQL Sample Database — Synthetic/Educational Data)

---

## VERIFIED KPIs FROM ACTUAL DATA
*(Run from powerbi_data_prep.py on your real dataset)*

| KPI | Value |
|---|---|
| **Total Revenue** | **$9,604,190.61** |
| **Total Orders** | **326** |
| **Unique Customers (ordered)** | **98** |
| **Total Quantity Sold** | **105,516 units** |
| **Average Order Value** | **$29,460.71** |
| **Total Payments Received** | **$8,853,839.23** |

### Revenue by Product Line
| Product Line | Revenue | Share |
|---|---|---|
| Classic Cars | $3,853,922.49 | 40.1% |
| Vintage Cars | $1,797,559.63 | 18.7% |
| Motorcycles | $1,121,426.12 | 11.7% |
| Trucks and Buses | $1,024,113.57 | 10.7% |
| Planes | $954,637.54 | 9.9% |
| Ships | $663,998.34 | 6.9% |
| Trains | $188,532.92 | 2.0% |

### Top 5 Customers by Revenue
| Customer | Revenue |
|---|---|
| Euro+ Shopping Channel | $820,689.54 |
| Mini Gifts Distributors Ltd. | $591,827.34 |
| Australian Collectors, Co. | $180,585.07 |
| Muscle Machine Inc | $177,913.95 |
| La Rochelle Gifts | $158,573.12 |

### Top 5 Sales Reps by Revenue
| Sales Rep | Revenue |
|---|---|
| Gerard Hernandez | $1,258,577.81 |
| Leslie Jennings | $1,081,530.54 |
| Pamela Castillo | $868,220.55 |
| Larry Bott | $732,096.79 |
| Barry Jones | $704,853.91 |

---

## STEP 1 — IMPORT DATA INTO POWER BI

Files to import from:
```
data\powerbi_ready\
```

**In Power BI Desktop:**
1. Click **Home** → **Get Data** → **Text/CSV**
2. Import each file in this order:
   - `DimDate.csv`
   - `DimCustomer.csv`
   - `DimEmployee.csv`
   - `DimOffice.csv`
   - `DimProduct.csv`
   - `FactOrderDetails.csv`
   - `FactPayments.csv`
3. For each file: click **Transform Data** and set column types correctly (see below)

### Column Types to Set in Power Query

**DimDate:**
- Date → Date
- Year, Month, Quarter, DayOfWeek → Whole Number
- MonthName, DayName, MonthYear, YearMonth, MonthShort → Text
- IsWeekend → True/False
- DateKey → Whole Number

**DimCustomer:**
- customerNumber, salesRepEmployeeNumber → Whole Number
- creditLimit → Decimal Number
- hasAssignedRep, isActiveCustomer → True/False
- All name/address fields → Text

**DimEmployee:**
- employeeNumber, officeCode, reportsTo → Whole Number
- All name/title/email fields → Text

**DimProduct:**
- quantityInStock → Whole Number
- buyPrice, MSRP, grossMargin, grossMarginPct → Decimal Number
- isLowStock → True/False

**FactOrderDetails:**
- orderNumber, orderLineNumber, customerNumber, salesRepEmployeeNumber → Whole Number
- quantityOrdered → Whole Number
- priceEach, lineRevenue, buyPrice, MSRP, grossMarginPct, daysToShip → Decimal Number
- orderDate → Date
- DateKey → Whole Number
- orderYear, orderMonth, orderQuarter → Whole Number
- isShipped → True/False

**FactPayments:**
- customerNumber → Whole Number
- amount → Decimal Number
- paymentDate → Date
- DateKey, paymentYear, paymentMonth → Whole Number

---

## STEP 2 — DATA MODEL (RELATIONSHIPS)

In **Model View**, create these relationships:

| From Table | From Column | To Table | To Column | Cardinality | Filter Direction |
|---|---|---|---|---|---|
| FactOrderDetails | customerNumber | DimCustomer | customerNumber | Many:1 | Single |
| FactOrderDetails | productCode | DimProduct | productCode | Many:1 | Single |
| FactOrderDetails | salesRepEmployeeNumber | DimEmployee | employeeNumber | Many:1 | Single |
| FactOrderDetails | DateKey | DimDate | DateKey | Many:1 | Single |
| FactPayments | customerNumber | DimCustomer | customerNumber | Many:1 | Single |
| FactPayments | DateKey | DimDate | DateKey | Many:1 | Single |
| DimEmployee | officeCode | DimOffice | officeCode | Many:1 | Single |

**Star Schema looks like this:**

```
                    DimDate
                       |
         DimProduct     |      DimCustomer
              \         |         /
               \        |        /
    DimEmployee -- FactOrderDetails -- FactPayments
               /
              /
         DimOffice
```

---

## STEP 3 — CREATE MEASURES TABLE

1. Home → Enter Data → name it `_Measures` → Load
2. Right-click `_Measures` → New Measure

Copy each DAX measure below:

### Core Revenue Measures

```dax
Total Revenue =
SUMX(
    FactOrderDetails,
    FactOrderDetails[quantityOrdered] * FactOrderDetails[priceEach]
)
```
> **Use:** KPI card, line charts, bar charts

```dax
Total Orders =
DISTINCTCOUNT(FactOrderDetails[orderNumber])
```
> **Use:** KPI card, trend charts

```dax
Total Customers =
DISTINCTCOUNT(DimCustomer[customerNumber])
```
> **Use:** KPI card

```dax
Total Quantity Sold =
SUM(FactOrderDetails[quantityOrdered])
```
> **Use:** KPI card, product analysis

```dax
Average Order Value =
DIVIDE([Total Revenue], [Total Orders], 0)
```
> **Use:** KPI card. Shows average spend per order = $29,460.71

```dax
Total Payments =
SUM(FactPayments[amount])
```
> **Use:** Financial summary card

---

### Time Intelligence Measures

```dax
Previous Month Revenue =
CALCULATE(
    [Total Revenue],
    PREVIOUSMONTH(DimDate[Date])
)
```
> **Use:** Month-over-month comparison card

```dax
Revenue Growth % =
DIVIDE(
    [Total Revenue] - [Previous Month Revenue],
    [Previous Month Revenue],
    0
)
```
> **Use:** KPI card with trend indicator. Format as percentage.

```dax
YTD Revenue =
CALCULATE(
    [Total Revenue],
    DATESYTD(DimDate[Date])
)
```
> **Use:** Year-to-date card

---

### Order Analysis Measures

```dax
Shipped Orders =
CALCULATE(
    [Total Orders],
    FactOrderDetails[status] = "Shipped"
)
```

```dax
Cancelled Orders =
CALCULATE(
    DISTINCTCOUNT(FactOrderDetails[orderNumber]),
    FactOrderDetails[status] = "Cancelled"
)
```

```dax
Cancelled Order Rate % =
DIVIDE(
    [Cancelled Orders],
    [Total Orders],
    0
) * 100
```
> **Use:** Shows cancelled order rate. Helps identify order fulfilment issues.

```dax
On Hold Orders =
CALCULATE(
    DISTINCTCOUNT(FactOrderDetails[orderNumber]),
    FactOrderDetails[status] = "On Hold"
)
```

---

### Customer Measures

```dax
Repeat Customers =
CALCULATE(
    DISTINCTCOUNT(FactOrderDetails[customerNumber]),
    FILTER(
        VALUES(FactOrderDetails[customerNumber]),
        CALCULATE(DISTINCTCOUNT(FactOrderDetails[orderNumber])) > 1
    )
)
```
> **Use:** Shows how many customers placed more than 1 order.

```dax
Repeat Customer Rate % =
DIVIDE([Repeat Customers], [Total Customers], 0) * 100
```
> **Use:** KPI card. Measures customer loyalty.

```dax
Avg Revenue Per Customer =
DIVIDE([Total Revenue], [Total Customers], 0)
```

---

### Product Measures

```dax
Avg Gross Margin % =
AVERAGE(DimProduct[grossMarginPct])
```
> **Use:** Shows average product markup. Based on MSRP vs buyPrice.
> Note: This is MSRP-based margin, not actual selling price margin.

```dax
Low Stock Products =
CALCULATE(
    COUNTROWS(DimProduct),
    DimProduct[isLowStock] = TRUE()
)
```
> **Use:** Inventory alert card. Currently 2 products below 100 units.

---

## STEP 4 — PAGE 1: EXECUTIVE OVERVIEW

### Layout (1280×720 or 16:9)

```
┌──────────────────────────────────────────────────────────┐
│  CLASSIC MODELS — Executive Dashboard          [Filters] │
│  [Year Slicer] [Product Line Slicer] [Country Slicer]   │
├────────┬────────┬────────┬────────┬────────┬────────────┤
│ Total  │ Total  │ Total  │ Total  │  AOV   │ Rev Growth │
│Revenue │Orders  │Custmrs │  Qty   │        │    %       │
├────────┴────────┴────────┴────────┴────────┴────────────┤
│                                                          │
│  Monthly Revenue Trend (Line Chart)        │  Order     │
│  X: YearMonth (ordered)                   │  Status    │
│  Y: Total Revenue                         │  Donut     │
│                                           │  Chart     │
├───────────────────────┬───────────────────┴────────────┤
│  Revenue by           │  Revenue by Country            │
│  Product Line         │  (Clustered Bar or Map)        │
│  (Horizontal Bar)     │                                │
└───────────────────────┴────────────────────────────────┘
```

### Visual Settings

**KPI Cards (top row):**
- Visual: Card
- Field: [Total Revenue], [Total Orders], [Total Customers], [Total Quantity Sold], [Average Order Value], [Revenue Growth %]
- Format: Currency ($), Comma-separated, 2 decimal places
- Background: Dark navy (#1a1a2e) or white with colored border
- Font: Segoe UI, 20pt value, 11pt label

**Monthly Revenue Trend (Line Chart):**
- X-axis: DimDate[YearMonth] — sort by DimDate[DateKey] (important!)
- Y-axis: [Total Revenue]
- Line color: #0078D4 (Power BI blue) or #2ecc71 (green)
- Add data labels: On
- Markers: Circle
- Tooltip: Also show [Total Orders]

**Order Status Donut:**
- Legend: FactOrderDetails[status]
- Values: [Total Orders]
- Colors:
  - Shipped → #2ecc71 (green)
  - Cancelled → #e74c3c (red)
  - On Hold → #f39c12 (orange)
  - In Process → #3498db (blue)
  - Resolved → #9b59b6 (purple)
  - Disputed → #e67e22 (dark orange)

**Revenue by Product Line (Horizontal Bar):**
- Y-axis: DimProduct[productLine]
- X-axis: [Total Revenue]
- Sort: Descending by [Total Revenue]
- Color: Gradient blue or categorical

**Revenue by Country (Clustered Bar):**
- Y-axis: DimCustomer[country]
- X-axis: [Total Revenue]
- Filter: Top 10 by [Total Revenue]
- Sort: Descending

**Slicers (top right):**
- DimDate[Year] — Dropdown
- DimProduct[productLine] — Dropdown
- DimCustomer[country] — Dropdown

---

## STEP 5 — PAGE 2: PRODUCT & SALES ANALYSIS

### Layout
```
┌──────────────────────────────────────────────────────────┐
│  PRODUCT & SALES ANALYSIS          [PL Slicer][Yr Slcr] │
├──────────────────────┬───────────────────────────────────┤
│ Top 10 Products      │  Product Line Revenue Matrix      │
│ by Revenue           │  (Matrix: PL × Year)              │
│ (Bar Chart)          │                                   │
├──────────────────────┼───────────────────────────────────┤
│ Top 10 Products      │  Gross Margin % by Product Line   │
│ by Qty Sold          │  (Bar Chart)                      │
│ (Bar Chart)          │                                   │
├──────────────────────┴───────────────────────────────────┤
│  Monthly Revenue by Product Line (Stacked Area Chart)   │
└──────────────────────────────────────────────────────────┘
```

**Top 10 Products by Revenue (Bar):**
- Y-axis: DimProduct[productName]
- X-axis: [Total Revenue]
- Filter: Top N = 10 by [Total Revenue]
- Sort: Descending

**Top 10 Products by Quantity (Bar):**
- Y-axis: DimProduct[productName]
- X-axis: [Total Quantity Sold]
- Filter: Top N = 10
- Sort: Descending

**Product Line Revenue Matrix:**
- Rows: DimProduct[productLine]
- Columns: DimDate[Year]
- Values: [Total Revenue]
- Format: Currency, conditional formatting (heat map)

**Gross Margin % by Product Line:**
- Y-axis: DimProduct[productLine]
- X-axis: [Avg Gross Margin %]
- Note: This uses MSRP vs buyPrice — label accordingly

**Stacked Area Chart:**
- X-axis: DimDate[YearMonth] (sorted by DateKey)
- Y-axis: [Total Revenue]
- Legend: DimProduct[productLine]

---

## STEP 6 — PAGE 3: CUSTOMER & REGIONAL ANALYSIS

### Layout
```
┌──────────────────────────────────────────────────────────┐
│  CUSTOMER & REGIONAL ANALYSIS    [Country][Rep][Yr] Slcr │
├──────────────────────┬───────────────────────────────────┤
│ Top 10 Customers     │  Revenue by Country (Bar)         │
│ by Revenue           │                                   │
│ (Bar Chart)          │                                   │
├──────────────────────┼───────────────────────────────────┤
│ Sales Rep            │  Customer KPIs                    │
│ Performance Table    │  - Total Customers: 122           │
│                      │  - Ordering Customers: 98         │
│                      │  - Repeat Customers: [calc]       │
│                      │  - Repeat Rate %: [calc]          │
├──────────────────────┴───────────────────────────────────┤
│  Revenue by Territory (EMEA / NA / APAC / Japan)         │
│  (Donut or Horizontal Bar)                               │
└──────────────────────────────────────────────────────────┘
```

**Top 10 Customers by Revenue:**
- Y-axis: DimCustomer[customerName]
- X-axis: [Total Revenue]
- Filter: Top 10 by [Total Revenue]
- Sort: Descending

**Revenue by Country:**
- Y-axis: DimCustomer[country]
- X-axis: [Total Revenue]
- Filter: Top 15 by [Total Revenue]
- Sort: Descending
- Use color gradient

**Sales Rep Performance Table:**
- Columns: DimEmployee[fullName], DimEmployee[territory], [Total Revenue], [Total Customers], [Total Orders]
- Sort: [Total Revenue] descending
- Conditional formatting on [Total Revenue] column

**Revenue by Territory:**
- Legend: DimEmployee[territory]
- Values: [Total Revenue]
- Type: Donut or Clustered Bar

**Customer KPI Cards:**
- Total Customers: 122 (all in DimCustomer)
- Customers who ordered: 98 (from FactOrderDetails distinct)
- Repeat Customers: [Repeat Customers measure]
- Repeat Rate %: [Repeat Customer Rate %]

---

## STEP 7 — FORMATTING RECOMMENDATIONS

### Color Theme
```
Primary Dark   : #1a1a2e  (dark navy — page background)
Primary Mid    : #16213e  (card backgrounds)
Accent Blue    : #0f3460  (headers)
Highlight      : #e94560  (KPI accents, high values)
Text Light     : #ffffff  (on dark backgrounds)
Text Dark      : #333333  (on light backgrounds)
Positive       : #2ecc71  (green — good metrics)
Negative       : #e74c3c  (red — alerts)
Neutral        : #f39c12  (orange — warnings)
```

### Alternative Light Theme
```
Background     : #f8f9fa
Card bg        : #ffffff
Primary        : #2563eb  (blue)
Accent         : #7c3aed  (purple)
Text           : #1f2937
Border         : #e5e7eb
```

### Fonts
- Title font: **Segoe UI Semibold**, 18pt
- Subtitle: **Segoe UI**, 14pt
- Body/labels: **Segoe UI**, 11pt
- KPI values: **Segoe UI Light**, 28pt

### Page Settings (each page)
- Width: 1280 px | Height: 720 px (16:9)
- Background: Set to theme color (dark or light)
- Page padding: 16px all sides

### Visual Formatting (apply to all visuals)
- Background: White (light theme) or #16213e (dark theme)
- Border: On, color #e5e7eb (light) or #0f3460 (dark), rounded corners
- Shadow: Soft
- Title: Bold, 13pt, left-aligned
- Grid lines: Horizontal only, light gray

---

## STEP 8 — SLICERS & FILTERS SETUP

### Recommended Slicers on Each Page

**Page 1 — Executive:**
```
- DimDate[Year]          → Dropdown slicer (sync to all pages)
- DimProduct[productLine] → Dropdown slicer
- DimCustomer[country]   → Dropdown slicer
```

**Page 2 — Products:**
```
- DimDate[Year]          → Dropdown (synced)
- DimProduct[productLine] → Tile slicer (shows all 7 product lines as clickable tiles)
```

**Page 3 — Customers:**
```
- DimDate[Year]          → Dropdown (synced)
- DimCustomer[country]   → Dropdown
- DimEmployee[fullName]  → Dropdown (filter by sales rep)
```

### Sync Slicers
1. View → Sync Slicers
2. Add Year slicer to all 3 pages and enable sync

---

## STEP 9 — TOOLTIPS & DRILL-THROUGH

### Custom Tooltip for Products
Create a Tooltip page (160×250, "tooltip" page type):
- Product Name
- Product Line
- Total Revenue
- Total Qty Sold
- Gross Margin %
- In Stock count

### Drill-Through on Customer
- Right-click on customer bar → Drill through → Customer Detail page
- Customer detail page shows: Orders over time, Products purchased, Payment history

---

## TROUBLESHOOTING

**Problem: YearMonth not sorting chronologically**
- Solution: In DimDate, select YearMonth column → Column Tools → Sort by Column → DateKey

**Problem: Map visual not showing all countries**
- Solution: In DimCustomer[country], set Data Category → Country/Region

**Problem: Measures not filtering correctly**
- Solution: Check relationship directions. All fact-to-dim relationships should be Single filter direction FROM dim TO fact.

**Problem: Revenue Growth % shows blank**
- Solution: Ensure DimDate[Date] column is marked as a date table (right-click DimDate → Mark as date table → Date column)

---

## POWER BI SERVICE PUBLISHING (Optional)

1. Save your .pbix file as:
   `ClassicModels_Dashboard.pbix`
2. Home → Publish → Select workspace
3. Set up scheduled refresh if connecting to live data
4. Share dashboard via Power BI Service link

---

*This guide is based on the ClassicModels sample database — a standard MySQL training dataset (NOT real company data). All KPI values shown are calculated from the actual synthetic dataset.*
