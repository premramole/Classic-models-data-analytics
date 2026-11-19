"""
=============================================================
  Classic Models — Power BI Data Prep Script
  Creates a single merged flat file optimised for Power BI
  import + individual star-schema ready CSVs.

  Run AFTER data_cleaning.py
  Output → data/powerbi_ready/
=============================================================
"""
import pandas as pd
import numpy as np
import os

BASE_PATH  = r"C:\Users\sathe\OneDrive\Desktop\power bi dashbord\classic-models-data-analytics"
CLEAN_PATH = os.path.join(BASE_PATH, "data", "cleaned")
PBI_PATH   = os.path.join(BASE_PATH, "data", "powerbi_ready")
os.makedirs(PBI_PATH, exist_ok=True)

# ------ Load cleaned tables --------------------------------
print("Loading cleaned tables …")
customers    = pd.read_csv(os.path.join(CLEAN_PATH, "customers_clean.csv"))
employees    = pd.read_csv(os.path.join(CLEAN_PATH, "employees_clean.csv"))
offices      = pd.read_csv(os.path.join(CLEAN_PATH, "offices_clean.csv"))
orders       = pd.read_csv(os.path.join(CLEAN_PATH, "orders_clean.csv"),
                            parse_dates=["orderDate","requiredDate","shippedDate"])
orderdetails = pd.read_csv(os.path.join(CLEAN_PATH, "orderdetails_clean.csv"))
payments     = pd.read_csv(os.path.join(CLEAN_PATH, "payments_clean.csv"),
                            parse_dates=["paymentDate"])
productlines = pd.read_csv(os.path.join(CLEAN_PATH, "productlines_clean.csv"))
products     = pd.read_csv(os.path.join(CLEAN_PATH, "products_clean.csv"))

# ===========================================================
# DIMENSION TABLES
# ===========================================================

# --- DimCustomer -------------------------------------------
print("Building DimCustomer …")
DimCustomer = customers[[
    "customerNumber","customerName","contactLastName","contactFirstName",
    "phone","addressLine1","addressLine2","city","state","postalCode",
    "country","salesRepEmployeeNumber","creditLimit",
    "hasAssignedRep","isActiveCustomer"
]].copy()
DimCustomer.to_csv(os.path.join(PBI_PATH, "DimCustomer.csv"), index=False)

# --- DimEmployee (with office territory) -------------------
print("Building DimEmployee …")
# Rename office cols before merge to avoid ambiguity
offices_slim = offices[["officeCode","city","country","territory"]].rename(
    columns={"city": "officeCity", "country": "officeCountry"}
)
emp_office = employees.merge(offices_slim, on="officeCode", how="left")

# Fix territory: NA offices have territory = NaN in our data; label them 'NA'
emp_office["territory"] = emp_office["territory"].fillna("NA")

DimEmployee = emp_office[[
    "employeeNumber","lastName","firstName","jobTitle",
    "email","extension","officeCode","officeCity","officeCountry","territory","reportsTo"
]].copy()
DimEmployee["fullName"] = DimEmployee["firstName"].str.strip() + " " + DimEmployee["lastName"].str.strip()
DimEmployee.to_csv(os.path.join(PBI_PATH, "DimEmployee.csv"), index=False)

# --- DimProduct --------------------------------------------
print("Building DimProduct …")
DimProduct = products.merge(
    productlines, on="productLine", how="left"
).rename(columns={"textDescription":"productLineDescription"})
DimProduct = DimProduct[[
    "productCode","productName","productLine","productLineDescription",
    "productVendor","quantityInStock","buyPrice","MSRP",
    "grossMargin","grossMarginPct","isLowStock"
]]
DimProduct.to_csv(os.path.join(PBI_PATH, "DimProduct.csv"), index=False)

# --- DimOffice ---------------------------------------------
print("Building DimOffice …")
DimOffice = offices.copy()
DimOffice["territory"] = DimOffice["territory"].fillna("NA")
DimOffice.to_csv(os.path.join(PBI_PATH, "DimOffice.csv"), index=False)

# --- DimDate -----------------------------------------------
print("Building DimDate …")
date_range = pd.date_range(start="2003-01-01", end="2005-12-31", freq="D")
DimDate = pd.DataFrame({"Date": date_range})
DimDate["Year"]        = DimDate["Date"].dt.year
DimDate["Quarter"]     = DimDate["Date"].dt.quarter
DimDate["Month"]       = DimDate["Date"].dt.month
DimDate["MonthName"]   = DimDate["Date"].dt.strftime("%B")
DimDate["MonthShort"]  = DimDate["Date"].dt.strftime("%b")
DimDate["MonthYear"]   = DimDate["Date"].dt.strftime("%b %Y")
DimDate["YearMonth"]   = DimDate["Date"].dt.to_period("M").astype(str)
DimDate["DayOfWeek"]   = DimDate["Date"].dt.dayofweek
DimDate["DayName"]     = DimDate["Date"].dt.strftime("%A")
DimDate["IsWeekend"]   = DimDate["DayOfWeek"] >= 5
DimDate["DateKey"]     = DimDate["Date"].dt.strftime("%Y%m%d").astype(int)
DimDate.to_csv(os.path.join(PBI_PATH, "DimDate.csv"), index=False)

# ===========================================================
# FACT TABLES
# ===========================================================

# --- FactOrderDetails (main fact) --------------------------
print("Building FactOrderDetails …")
fact_od = orderdetails.merge(
    orders[["orderNumber","orderDate","status","customerNumber",
            "orderYear","orderMonth","orderQuarter","orderYearMonth",
            "isShipped","daysToShip"]],
    on="orderNumber", how="left"
).merge(
    customers[["customerNumber","salesRepEmployeeNumber","country","city","creditLimit","isActiveCustomer"]],
    on="customerNumber", how="left"
).merge(
    products[["productCode","productLine","buyPrice","MSRP","grossMarginPct"]],
    on="productCode", how="left"
)

# Rename for clarity
fact_od.rename(columns={
    "country": "customerCountry",
    "city"   : "customerCity"
}, inplace=True)

# Add date key for relationship with DimDate
fact_od["DateKey"] = pd.to_datetime(fact_od["orderDate"]).dt.strftime("%Y%m%d").astype(int)

FactOrderDetails = fact_od[[
    "orderNumber","orderLineNumber","productCode","productLine",
    "customerNumber","salesRepEmployeeNumber",
    "customerCountry","customerCity",
    "quantityOrdered","priceEach","lineRevenue",
    "buyPrice","MSRP","grossMarginPct",
    "orderDate","DateKey","orderYear","orderMonth","orderQuarter","orderYearMonth",
    "status","isShipped","daysToShip"
]]
FactOrderDetails.to_csv(os.path.join(PBI_PATH, "FactOrderDetails.csv"), index=False)

# --- FactPayments ------------------------------------------
print("Building FactPayments …")
FactPayments = payments.merge(
    customers[["customerNumber","customerName","country","salesRepEmployeeNumber"]],
    on="customerNumber", how="left"
)
FactPayments["DateKey"] = FactPayments["paymentDate"].dt.strftime("%Y%m%d").astype(int)
FactPayments = FactPayments[[
    "customerNumber","customerName","checkNumber","paymentDate",
    "DateKey","paymentYear","paymentMonth","amount","country","salesRepEmployeeNumber"
]]
FactPayments.to_csv(os.path.join(PBI_PATH, "FactPayments.csv"), index=False)

# ===========================================================
# SUMMARY VERIFICATION
# ===========================================================
print("\n" + "="*60)
print("  POWER BI READY FILES — Summary")
print("="*60)
for f in sorted(os.listdir(PBI_PATH)):
    df = pd.read_csv(os.path.join(PBI_PATH, f))
    print(f"  {f:<35} {len(df):>5} rows | {len(df.columns):>2} cols")

total_rev  = FactOrderDetails["lineRevenue"].sum()
total_ord  = FactOrderDetails["orderNumber"].nunique()
total_cust = FactOrderDetails["customerNumber"].nunique()
total_qty  = FactOrderDetails["quantityOrdered"].sum()
aov        = total_rev / total_ord

print("="*60)
print(f"\n  KEY KPIs (verified from actual data):")
print(f"  Total Revenue        : ${total_rev:>14,.2f}")
print(f"  Total Orders         : {total_ord:>14,}")
print(f"  Total Customers      : {total_cust:>14,}")
print(f"  Total Qty Sold       : {total_qty:>14,}")
print(f"  Avg Order Value      : ${aov:>14,.2f}")
print(f"  Total Payments       : ${payments['amount'].sum():>14,.2f}")
print("="*60)

# Revenue by product line
rev_by_line = (FactOrderDetails
    .groupby("productLine")["lineRevenue"]
    .sum()
    .sort_values(ascending=False)
)
print("\n  Revenue by Product Line:")
for line, rev in rev_by_line.items():
    pct = rev / total_rev * 100
    print(f"    {line:<22} ${rev:>12,.2f}  ({pct:5.1f}%)")

# Top 5 customers by revenue
top_cust = (FactOrderDetails
    .groupby("customerNumber")["lineRevenue"]
    .sum()
    .reset_index()
    .merge(customers[["customerNumber","customerName"]], on="customerNumber")
    .sort_values("lineRevenue", ascending=False)
    .head(5)
)
print("\n  Top 5 Customers by Revenue:")
for _, row in top_cust.iterrows():
    print(f"    {row['customerName']:<35} ${row['lineRevenue']:>12,.2f}")

# Top 5 sales reps
top_reps = (FactOrderDetails
    .groupby("salesRepEmployeeNumber")["lineRevenue"]
    .sum()
    .reset_index()
    .merge(DimEmployee[["employeeNumber","fullName","territory"]],
           left_on="salesRepEmployeeNumber", right_on="employeeNumber", how="left")
    .sort_values("lineRevenue", ascending=False)
    .head(5)
)
print("\n  Top 5 Sales Reps by Revenue:")
for _, row in top_reps.iterrows():
    print(f"    {str(row['fullName']):<30} ${row['lineRevenue']:>12,.2f}")

print(f"\n  All files saved to: {PBI_PATH}")
print("  Import these into Power BI Desktop via:")
print("  Home → Get Data → Text/CSV → select each file")
print("="*60)
