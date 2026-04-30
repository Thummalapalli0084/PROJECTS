-- =============================================================
--  RETAIL MARGIN ANALYTICS — Step 3: SQL Business Queries
--  Business Problem: Profit margins shrinking despite high sales.
--  Database: SQLite / MySQL / PostgreSQL compatible
--  Table   : retail_sales  (imported from retail_clean_data.csv)
-- =============================================================
 
-- ─────────────────────────────────────────────────────────────
-- SETUP: Create & populate table (SQLite syntax)
-- In MySQL/PostgreSQL replace TEXT with VARCHAR(100), etc.
-- ─────────────────────────────────────────────────────────────


CREATE TABLE IF NOT EXISTS retail_sales (
    Order_ID           TEXT,
    Order_Date         DATE,
    Ship_Date          DATE,
    Customer_ID        TEXT,
    Gender             TEXT,
    Age                INTEGER,
    Region             TEXT,
    Category           TEXT,
    Freight_Mode       TEXT,
    Quantity           INTEGER,
    Unit_Price         REAL,
    Discount_Pct       REAL,
    Original_Amount    REAL,
    Sales              REAL,
    COGS               REAL,
    Freight_Cost       REAL,
    Profit             REAL,
    Profit_Margin_Pct  REAL,
    Delivery_Days      INTEGER,
    Year               INTEGER,
    Month              INTEGER,
    Month_Name         TEXT,
    Age_Group          TEXT,
    Disc_Band          TEXT
);
 
-- Import via:  .import --csv retail_clean_data.csv retail_sales  (SQLite CLI)
-- Or in Python: df.to_sql('retail_sales', conn, if_exists='replace', index=False)
 
 
-- =============================================================
-- QUERY 1: LOW-MARGIN PRODUCTS (< 30%)
-- Business Q: Which categories drag down overall profitability?
-- =============================================================
 
SELECT
    Category,
    COUNT(*)                          AS Total_Transactions,
    ROUND(AVG(Profit_Margin_Pct), 2)  AS Avg_Margin_Pct,
    ROUND(SUM(Sales), 2)              AS Total_Sales,
    ROUND(SUM(Profit), 2)             AS Total_Profit,
    ROUND(SUM(Freight_Cost), 2)       AS Total_Freight,
    COUNT(CASE WHEN Profit_Margin_Pct < 30 THEN 1 END) AS Low_Margin_Count,
    ROUND(
        100.0 * COUNT(CASE WHEN Profit_Margin_Pct < 30 THEN 1 END) / COUNT(*), 1
    )                                 AS Low_Margin_Pct
FROM retail_sales
GROUP BY Category
ORDER BY Avg_Margin_Pct ASC;
 
/*
 EXPECTED INSIGHT:
 Electronics has lowest avg margin (~0.6%) — Express/Priority shipping
 eats most profit. Beauty has best margin (~12.6%).
*/
 
 
-- =============================================================
-- QUERY 2: FREIGHT MODE EFFICIENCY ANALYSIS
-- Business Q: Which shipping mode costs most vs speed delivered?
-- =============================================================
 
SELECT
    Freight_Mode,
    COUNT(*)                            AS Orders,
    ROUND(AVG(Freight_Cost), 2)         AS Avg_Freight_Cost,
    ROUND(AVG(Delivery_Days), 1)        AS Avg_Delivery_Days,
    ROUND(AVG(Profit_Margin_Pct), 2)    AS Avg_Margin_Pct,
    ROUND(SUM(Freight_Cost), 2)         AS Total_Freight_Spend,
    ROUND(AVG(Freight_Cost / NULLIF(Sales, 0)) * 100, 2) AS Freight_As_Pct_Of_Sales
FROM retail_sales
GROUP BY Freight_Mode
ORDER BY Avg_Freight_Cost DESC;
 
/*
 EXPECTED INSIGHT:
 Express mode: avg freight ₹121 but avg margin = -12.95% (loss-making!)
 Economy mode: avg freight ₹19, avg margin = 25.67% — most efficient.
 RECOMMENDATION: Shift standard/express orders to Economy where delivery
 timeline allows (13.6 days average).
*/
 
 
-- =============================================================
-- QUERY 3: DISCOUNT IMPACT BY CATEGORY
-- Business Q: Does discounting drive enough extra sales to justify margin loss?
-- =============================================================
 
SELECT
    Category,
    Disc_Band,
    COUNT(*)                          AS Transactions,
    ROUND(AVG(Discount_Pct), 1)       AS Avg_Discount_Pct,
    ROUND(SUM(Sales), 2)              AS Total_Revenue,
    ROUND(AVG(Profit_Margin_Pct), 2)  AS Avg_Margin_Pct,
    ROUND(SUM(Profit), 2)             AS Total_Profit,
    ROUND(AVG(Quantity), 2)           AS Avg_Units_Per_Order
FROM retail_sales
GROUP BY Category, Disc_Band
ORDER BY Category, Avg_Discount_Pct;
 
/*
 EXPECTED INSIGHT:
 Electronics: even No-Discount orders show near-zero margin — root cause
 is high freight, not discounting.
 Clothing: 21%+ discount kills margin entirely.
 Beauty: best ROI at 1-10% discount band.
 RECOMMENDATION: Cap clothing discounts at 10%. Run Beauty promotions.
*/
 
 
-- =============================================================
-- QUERY 4: REGIONAL PERFORMANCE DEEP-DIVE
-- Business Q: Are some regions consistently underperforming?
-- =============================================================
 
SELECT
    Region,
    COUNT(*)                          AS Transactions,
    ROUND(SUM(Sales), 2)              AS Total_Sales,
    ROUND(SUM(Profit), 2)             AS Total_Profit,
    ROUND(AVG(Profit_Margin_Pct), 2)  AS Avg_Margin_Pct,
    ROUND(SUM(Freight_Cost), 2)       AS Total_Freight,
    ROUND(
        100.0 * SUM(Freight_Cost) / NULLIF(SUM(Sales), 0), 2
    )                                 AS Freight_Pct_Of_Sales
FROM retail_sales
GROUP BY Region
ORDER BY Avg_Margin_Pct DESC;
 
 
-- =============================================================
-- QUERY 5: TOP 10 MOST LOSS-MAKING TRANSACTION PROFILES
-- Business Q: What combinations are destroying the most value?
-- =============================================================
 
SELECT
    Order_ID,
    Category,
    Freight_Mode,
    Region,
    Discount_Pct,
    Sales,
    Freight_Cost,
    Profit,
    ROUND(Profit_Margin_Pct, 2) AS Margin_Pct
FROM retail_sales
WHERE Profit < 0
ORDER BY Profit ASC
LIMIT 10;
 
 
-- =============================================================
-- QUERY 6: GENDER × AGE GROUP — SALES & MARGIN SEGMENTATION
-- Business Q: Which customer segments are most profitable?
-- =============================================================
 
SELECT
    Gender,
    Age_Group,
    COUNT(*)                          AS Transactions,
    ROUND(AVG(Sales), 2)              AS Avg_Order_Value,
    ROUND(AVG(Profit_Margin_Pct), 2)  AS Avg_Margin_Pct,
    ROUND(SUM(Profit), 2)             AS Total_Profit
FROM retail_sales
GROUP BY Gender, Age_Group
ORDER BY Avg_Margin_Pct DESC;
 
 
-- =============================================================
-- QUERY 7: MONTHLY SALES TREND WITH ROLLING MARGIN
-- Business Q: Is the margin problem getting worse over time?
-- =============================================================
 
SELECT
    Year,
    Month,
    Month_Name,
    COUNT(*)                          AS Transactions,
    ROUND(SUM(Sales), 2)              AS Monthly_Sales,
    ROUND(SUM(Profit), 2)             AS Monthly_Profit,
    ROUND(AVG(Profit_Margin_Pct), 2)  AS Avg_Margin_Pct,
    ROUND(SUM(Freight_Cost), 2)       AS Monthly_Freight
FROM retail_sales
GROUP BY Year, Month, Month_Name
ORDER BY Year, Month;
 
 
-- =============================================================
-- QUERY 8: EXECUTIVE KPI SUMMARY (for Power BI card visuals)
-- =============================================================
 
SELECT
    'Total Sales'           AS KPI, ROUND(SUM(Sales), 0)              AS Value FROM retail_sales
UNION ALL
SELECT 'Total Profit',               ROUND(SUM(Profit), 0)             FROM retail_sales
UNION ALL
SELECT 'Total Freight Cost',         ROUND(SUM(Freight_Cost), 0)       FROM retail_sales
UNION ALL
SELECT 'Avg Profit Margin %',        ROUND(AVG(Profit_Margin_Pct), 2)  FROM retail_sales
UNION ALL
SELECT 'Low-Margin Transactions',    COUNT(*)
    FROM retail_sales WHERE Profit_Margin_Pct < 30
UNION ALL
SELECT 'Loss-Making Transactions',   COUNT(*)
    FROM retail_sales WHERE Profit < 0;
 
 
-- =============================================================
-- QUERY 9: FREIGHT OPTIMIZATION RECOMMENDATION
-- Best mode per category by margin
-- =============================================================
 
SELECT
    Category,
    Freight_Mode,
    ROUND(AVG(Profit_Margin_Pct), 2) AS Avg_Margin,
    ROUND(AVG(Freight_Cost), 2)      AS Avg_Freight_Cost,
    ROUND(AVG(Delivery_Days), 1)     AS Avg_Delivery_Days,
    COUNT(*)                         AS Orders
FROM retail_sales
GROUP BY Category, Freight_Mode
ORDER BY Category, Avg_Margin DESC;
 
/*
 USE THIS QUERY TO TELL LEADERSHIP:
 "For Electronics, switching from Express to Economy saves ₹102/order
  and improves margin by ~13 percentage points."
*/
 