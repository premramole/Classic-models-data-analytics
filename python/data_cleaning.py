"""
=============================================================
  Classic Models E-Commerce — Data Cleaning Script
  File: data_cleaning.py
  Purpose: Clean all 8 raw CSVs and produce Power BI-ready
           cleaned CSVs in data/cleaned/
  Dataset: ClassicModels sample/synthetic database
           (NOT real company data)
=============================================================
"""

import pandas as pd
import numpy as np
import os
import sys

# ----------------------------------------------------------
# PATH CONFIGURATION
# ----------------------------------------------------------
BASE_PATH = r"C:\Users\sathe\OneDrive\Desktop\power bi dashbord\classic-models-data-analytics"
RAW_PATH  = os.path.join(BASE_PATH, "data", "raw")
CLEAN_PATH = os.path.join(BASE_PATH, "data", "cleaned")
os.makedirs(CLEAN_PATH, exist_ok=True)

print("=" * 65)
print("  Classic Models — Data Cleaning Pipeline")
print("=" * 65)
print(f"  Raw data   : {RAW_PATH}")
print(f"  Cleaned to : {CLEAN_PATH}")
print("=" * 65)


def replace_null_strings(df):
    """Replace literal string 'NULL' with np.nan across entire dataframe."""
    return df.replace("NULL", np.nan)


def trim_strings(df):
    """Strip leading/trailing whitespace from all string columns."""
    str_cols = df.select_dtypes(include="object").columns
    df[str_cols] = df[str_cols].apply(lambda c: c.str.strip())
    return df


def null_summary(df, label):
    nulls = df.isnull().sum()
    nulls = nulls[nulls > 0]
    if len(nulls):
        print(f"  Remaining NULLs in {label}:")
        for col, cnt in nulls.items():
            print(f"    {col}: {cnt}")
    else:
        print(f"  No NULLs remain in {label}")


# ===========================================================
# 1. CUSTOMERS
# ===========================================================
print("\n[1/8] Cleaning customers ...")
customers = pd.read_csv(os.path.join(RAW_PATH, "customers.csv"))
customers = replace_null_strings(customers)
# The first unnamed column is actually customerNumber
customers.rename(columns={customers.columns[0]: "customerNumber"}, inplace=True)
# Fix nullable columns
customers["addressLine2"] = customers["addressLine2"].fillna("")
customers["state"]        = customers["state"].fillna("")
customers["postalCode"]   = customers["postalCode"].fillna("")
# Sales rep: keep NaN as 0, add flag
customers["hasAssignedRep"] = customers["salesRepEmployeeNumber"].notna()
customers["salesRepEmployeeNumber"] = customers["salesRepEmployeeNumber"].fillna(0).astype(int)
# Active customer flag
customers["isActiveCustomer"] = customers["creditLimit"].astype(float) > 0
customers = trim_strings(customers)
customers["customerNumber"] = customers["customerNumber"].astype(int)
customers["creditLimit"]    = customers["creditLimit"].astype(float)
customers.to_csv(os.path.join(CLEAN_PATH, "customers_clean.csv"), index=False)
print(f"  Rows: {len(customers)} | Cols: {len(customers.columns)}")
print(f"  New cols: hasAssignedRep, isActiveCustomer")
print(f"  Customers with no rep: {(~customers['hasAssignedRep']).sum()}")
print(f"  Inactive customers (creditLimit=0): {(~customers['isActiveCustomer']).sum()}")
null_summary(customers, "customers")


# ===========================================================
# 2. EMPLOYEES
# ===========================================================
print("\n[2/8] Cleaning employees ...")
employees = pd.read_csv(os.path.join(RAW_PATH, "employees.csv"))
employees = replace_null_strings(employees)
# reportsTo is NULL only for President — fill with 0
employees["reportsTo"] = employees["reportsTo"].fillna(0).astype(int)
employees = trim_strings(employees)
employees.to_csv(os.path.join(CLEAN_PATH, "employees_clean.csv"), index=False)
print(f"  Rows: {len(employees)} | Cols: {len(employees.columns)}")
print(f"  Job titles: {employees['jobTitle'].value_counts().to_dict()}")
null_summary(employees, "employees")


# ===========================================================
# 3. OFFICES
# ===========================================================
print("\n[3/8] Cleaning offices ...")
offices = pd.read_csv(os.path.join(RAW_PATH, "offices.csv"))
offices = replace_null_strings(offices)
offices["addressLine2"] = offices["addressLine2"].fillna("")
offices["state"]        = offices["state"].fillna("")
offices = trim_strings(offices)
offices.to_csv(os.path.join(CLEAN_PATH, "offices_clean.csv"), index=False)
print(f"  Rows: {len(offices)} | Cols: {len(offices.columns)}")
print(f"  Territories: {offices['territory'].unique().tolist()}")
null_summary(offices, "offices")


# ===========================================================
# 4. ORDERS
# ===========================================================
print("\n[4/8] Cleaning orders ...")
orders = pd.read_csv(os.path.join(RAW_PATH, "orders.csv"))
orders = replace_null_strings(orders)
# Fill comments
orders["comments"] = orders["comments"].fillna("")
# Convert dates
orders["orderDate"]    = pd.to_datetime(orders["orderDate"],    errors="coerce")
orders["requiredDate"] = pd.to_datetime(orders["requiredDate"], errors="coerce")
orders["shippedDate"]  = pd.to_datetime(orders["shippedDate"],  errors="coerce")
# Add flags and time-based columns
orders["isShipped"]   = orders["shippedDate"].notna()
orders["orderYear"]   = orders["orderDate"].dt.year
orders["orderMonth"]  = orders["orderDate"].dt.month
orders["orderQuarter"]= orders["orderDate"].dt.quarter
orders["orderYearMonth"] = orders["orderDate"].dt.to_period("M").astype(str)
orders["daysToShip"]  = (orders["shippedDate"] - orders["orderDate"]).dt.days
orders = trim_strings(orders)
orders.to_csv(os.path.join(CLEAN_PATH, "orders_clean.csv"), index=False)
print(f"  Rows: {len(orders)} | Cols: {len(orders.columns)}")
print(f"  Date range: {orders['orderDate'].min().date()} to {orders['orderDate'].max().date()}")
print(f"  Status counts: {orders['status'].value_counts().to_dict()}")
print(f"  New cols: isShipped, orderYear, orderMonth, orderQuarter, orderYearMonth, daysToShip")
null_summary(orders, "orders")


# ===========================================================
# 5. ORDER DETAILS
# ===========================================================
print("\n[5/8] Cleaning orderdetails ...")
orderdetails = pd.read_csv(os.path.join(RAW_PATH, "orderdetails.csv"))
orderdetails = replace_null_strings(orderdetails)
# Calculate line revenue
orderdetails["lineRevenue"] = (
    orderdetails["quantityOrdered"].astype(float) *
    orderdetails["priceEach"].astype(float)
).round(2)
orderdetails.to_csv(os.path.join(CLEAN_PATH, "orderdetails_clean.csv"), index=False)
print(f"  Rows: {len(orderdetails)} | Cols: {len(orderdetails.columns)}")
total_rev = orderdetails["lineRevenue"].sum()
print(f"  Total Revenue (all orders): ${total_rev:,.2f}")
print(f"  New cols: lineRevenue")
null_summary(orderdetails, "orderdetails")


# ===========================================================
# 6. PAYMENTS
# ===========================================================
print("\n[6/8] Cleaning payments ...")
payments = pd.read_csv(os.path.join(RAW_PATH, "payments.csv"))
payments = replace_null_strings(payments)
payments["paymentDate"]  = pd.to_datetime(payments["paymentDate"], errors="coerce")
payments["paymentYear"]  = payments["paymentDate"].dt.year
payments["paymentMonth"] = payments["paymentDate"].dt.month
payments["amount"]       = payments["amount"].astype(float)
payments.to_csv(os.path.join(CLEAN_PATH, "payments_clean.csv"), index=False)
print(f"  Rows: {len(payments)} | Cols: {len(payments.columns)}")
print(f"  Total Payments: ${payments['amount'].sum():,.2f}")
print(f"  New cols: paymentYear, paymentMonth")
null_summary(payments, "payments")


# ===========================================================
# 7. PRODUCT LINES
# ===========================================================
print("\n[7/8] Cleaning productlines ...")
productlines = pd.read_csv(os.path.join(RAW_PATH, "productlines.csv"))
productlines = replace_null_strings(productlines)
# Drop entirely NULL columns
cols_to_drop = [c for c in ["htmlDescription", "image"] if c in productlines.columns]
productlines.drop(columns=cols_to_drop, inplace=True)
print(f"  Dropped entirely-NULL columns: {cols_to_drop}")
productlines = trim_strings(productlines)
productlines.to_csv(os.path.join(CLEAN_PATH, "productlines_clean.csv"), index=False)
print(f"  Rows: {len(productlines)} | Cols: {len(productlines.columns)}")
print(f"  Product lines: {productlines['productLine'].tolist()}")
null_summary(productlines, "productlines")


# ===========================================================
# 8. PRODUCTS
# ===========================================================
print("\n[8/8] Cleaning products ...")
products = pd.read_csv(os.path.join(RAW_PATH, "products.csv"))
products = replace_null_strings(products)
products = trim_strings(products)
products["buyPrice"] = products["buyPrice"].astype(float)
products["MSRP"]     = products["MSRP"].astype(float)
products["quantityInStock"] = products["quantityInStock"].astype(int)
# Derived columns
products["grossMargin"]    = (products["MSRP"] - products["buyPrice"]).round(2)
products["grossMarginPct"] = ((products["MSRP"] - products["buyPrice"]) / products["MSRP"] * 100).round(2)
products["isLowStock"]     = products["quantityInStock"] < 100
products.to_csv(os.path.join(CLEAN_PATH, "products_clean.csv"), index=False)
print(f"  Rows: {len(products)} | Cols: {len(products.columns)}")
print(f"  Low-stock products: {products['isLowStock'].sum()}")
low_stock_items = products[products["isLowStock"]][["productCode","productName","quantityInStock"]]
print(f"  Low-stock items:\n{low_stock_items.to_string(index=False)}")
print(f"  New cols: grossMargin, grossMarginPct, isLowStock")
null_summary(products, "products")


# ===========================================================
# SUMMARY
# ===========================================================
print("\n" + "=" * 65)
print("  CLEANING COMPLETE — Summary")
print("=" * 65)
clean_files = [f for f in os.listdir(CLEAN_PATH) if f.endswith(".csv")]
for f in sorted(clean_files):
    df = pd.read_csv(os.path.join(CLEAN_PATH, f))
    print(f"  {f:<35} {len(df):>5} rows | {len(df.columns):>2} cols")
print("=" * 65)
print(f"\n  All cleaned CSVs saved to: {CLEAN_PATH}")
print("  These files are ready for:")
print("    - Power BI import")
print("    - Jupyter notebook analysis")
print("    - Excel analysis")
print("=" * 65)
