# 🍔 Swiggy SQL Data Analysis Project

## 📌 Project Overview
This project performs end-to-end data analysis on Swiggy food delivery data using SQL.
A star schema data warehouse is designed to generate business insights such as revenue,
order trends, rating analysis, and cuisine performance.

## 🛠 Tools & Technologies
- MySQL
- SQL (Joins, Aggregations, Window Functions)
- GitHub

## 🗂 Dataset
- Source: Swiggy Orders Dataset (CSV)
- Records: Orders with price, rating, city, restaurant, dish, category, date

## 🏗 Database Design
Star Schema:
- Fact Table: `fact_swiggy_orders`
- Dimension Tables:
  - `dim_date`
  - `dim_location`
  - `dim_restaurant`
  - `dim_category`
  - `dim_dish`

## 📊 Key Analysis Performed
- Top cities by order volume
- Revenue contribution by state
- Top restaurants & categories by orders
- Most ordered dishes
- Cuisine performance (orders + avg rating)
- Price range analysis
- Rating distribution (1–5)
- Time-based analysis (year, quarter, weekday)

## 🔍 Sample Query
```sql
SELECT
    l.city,
    SUM(f.`Price (INR)`) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l
    ON f.location_id = l.location_id
GROUP BY l.city
ORDER BY Total_Revenue DESC
LIMIT 10;
