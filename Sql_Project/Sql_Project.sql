CREATE DATABASE SWIGGY_PROJECT ;
USE SWIGGY_PROJECT ;

CREATE TABLE swiggy_data (
    `State` VARCHAR(50),
    `City` VARCHAR(50),
    `Order Date` DATE,
    `Restaurant Name` VARCHAR(255),
    `Location` VARCHAR(150),
    `Category` VARCHAR(255),
    `Dish Name` VARCHAR(255),
    `Price (INR)` DECIMAL(10,2),
    `Rating` DECIMAL(2,1),
    `Rating Count` INT
);

LOAD DATA LOCAL INFILE 
'C:/Users/krish/Downloads/Dinesh_resumes/SQL_PROJECT/drive-download-20251225T105125Z-1-001/swiggy_data(1).csv'
INTO TABLE swiggy_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


SELECT COUNT(*) FROM swiggy_data;
describe  swiggy_data ;
-- DATA VADILATION &  CHECKING  :
-- NULL CHECK :
SELECT 
    SUM(CASE WHEN `State` IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN `City` IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN `Order Date` IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN `Restaurant Name` IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
    SUM(CASE WHEN `Location` IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN `Category` IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN `Dish Name` IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
    SUM(CASE WHEN `Price (INR)` IS NULL THEN 1 ELSE 0 END) AS null_price_inr,
    SUM(CASE WHEN `Rating` IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN `Rating Count` IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;

-- BLANK OR EMPTY STRING

SELECT *
FROM swiggy_data
WHERE 
    TRIM(`State`) = ''
 OR TRIM(`City`) = ''
 OR TRIM(`Restaurant Name`) = ''
 OR TRIM(`Location`) = ''
 OR TRIM(`Category`) = ''
 OR TRIM(`Dish Name`) = '';
 
 -- DUPLICATE DETECTION
 
 SELECT 
    `State`, `City`, `Order Date`, `Restaurant Name`, 
    `Location`, `Category`, `Dish Name`, 
    `Price (INR)`, `Rating`, `Rating Count`,
    COUNT(*) AS duplicate_count
FROM swiggy_data
GROUP BY 
    `State`, `City`, `Order Date`, `Restaurant Name`, 
    `Location`, `Category`, `Dish Name`, 
    `Price (INR)`, `Rating`, `Rating Count`
HAVING COUNT(*) > 1;

-- DUPLICATE DELETE :
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   `State`, `City`, `Order Date`, `Restaurant Name`,
                   `Location`, `Category`, `Dish Name`,
                   `Price (INR)`, `Rating`, `Rating Count`
               ORDER BY `Order Date`
           ) AS rn
    FROM swiggy_data
) t
WHERE rn > 1;

-- CREATING SCHEMA :
-- DIMESION TABLES :
-- DATE TABLE :

CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(25),
    quarter INT,
    day INT,
    week INT
);

-- dim_location :
CREATE TABLE dim_location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    state VARCHAR(100),
    city VARCHAR(100),
    location VARCHAR(200)
);


-- dim_restaurant
CREATE TABLE dim_restaurant (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(200)
);

-- dim_category 
CREATE TABLE dim_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(200)
);


-- -- dim_dish 
CREATE TABLE dim_dish(
dish_id INT AUTO_INCREMENT PRIMARY KEY,
Dish_Name  VARCHAR(200)
)
select * from swiggy_data ;
-- FACT TABLE:

CREATE TABLE fact_swiggy_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,

    date_id INT,
    `Price (INR)` DECIMAL(10,2),
    Rating DECIMAL(4,2),
    Rating_Count INT,

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);


-- INSERT DATA TABLE IN VALUES :
-- dim_date 
INSERT INTO dim_date 
(full_date, year, month, month_name, quarter, day, week)
SELECT DISTINCT 
    `Order Date` AS full_date,
    YEAR(`Order Date`) AS year,
    MONTH(`Order Date`) AS month,
    MONTHNAME(`Order Date`) AS month_name,
    QUARTER(`Order Date`) AS quarter,
    DAY(`Order Date`) AS day,
    WEEK(`Order Date`) AS week
FROM swiggy_data
WHERE `Order Date` IS NOT NULL;

-- dim_location 
INSERT INTO dim_location ( State , City , Location )
SELECT DISTINCT 
State,City, Location 
FROM swiggy_data ;

-- dim_restaurant 
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT
    `Restaurant Name`
FROM swiggy_data
WHERE `Restaurant Name` IS NOT NULL;


-- dim_category 
INSERT INTO dim_category (Category)
SELECT DISTINCT 
Category 	 
FROM swiggy_data;

-- dim_dish 

INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT 
    `Dish Name`
FROM swiggy_data
;

-- FACT TABLE :

INSERT INTO fact_swiggy_orders (
    date_id,
    `Price (INR)`,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.`Price (INR)`,
    s.Rating,
    s.`Rating Count`,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM swiggy_data s

JOIN dim_date dd
    ON dd.full_date = s.`Order Date`

JOIN dim_location dl
    ON dl.state = s.`State`
   AND dl.city = s.`City`
   AND dl.location = s.`Location`

JOIN dim_restaurant dr
    ON dr.restaurant_name = s.`Restaurant Name`

JOIN dim_category dc
    ON dc.category = s.`Category`

JOIN dim_dish dsh
    ON dsh.Dish_Name = s.`Dish Name`;


select *from fact_swiggy_orders ;


SELECT *
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
JOIN dim_location l 
    ON f.location_id = l.location_id
JOIN dim_restaurant r 
    ON f.restaurant_id = r.restaurant_id
JOIN dim_category c 
    ON f.category_id = c.category_id
JOIN dim_dish di 
    ON f.dish_id = di.dish_id;

-- KPI's
-- TOTAL ORDERS :
SELECT COUNT(*) AS Total_Orders 
FROM fact_swiggy_orders

-- TOTAL REVENUE  (INR MILLION)
SELECT
    CONCAT(
        FORMAT(SUM(`Price (INR)`) / 1000000, 2),
        ' INR MILLION'
    ) AS Total_Revenue
FROM fact_swiggy_orders;

-- AVERAGE  DISH PRICE :
SELECT
    ROUND(AVG(`Price (INR)`), 2) AS Average_Dish_Price_INR
FROM fact_swiggy_orders;

-- AVERAGE RATING
SELECT
    ROUND(AVG(Rating), 2) AS Average_Rating
FROM fact_swiggy_orders;


-- DEEP DIVE BUSINESS ANALYSIS :

-- MONTHLY ORDERS TRENDS 

SELECT 
d.year,d.month,d.month_name ,count(*) AS Total_Orders 
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY 
d.year,d.month,d.month_name 
ORDER BY COUNT(*) DESC ;

-- QUARTERLY TREND 
SELECT
    d.year,
    d.quarter,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
GROUP BY
    d.year,
    d.quarter
ORDER BY Total_Orders DESC;

-- YEARLY TREND
SELECT 
d.year,count(*) AS Total_Orders 
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY 
d.year 
ORDER BY COUNT(*) DESC ;

-- Orders by Day of Week (Mon-Sun)

SELECT
    DAYNAME(d.full_date) AS day_name,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
GROUP BY
    DAYNAME(d.full_date),
    WEEKDAY(d.full_date)
ORDER BY
    WEEKDAY(d.full_date);

-- Top 10 Cities by Order Volume

SELECT
    l.city,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_location l
    ON f.location_id = l.location_id
GROUP BY l.city
ORDER BY Total_Orders DESC;

-- Top 10 Cities by Total Revenue (Sum of Price)
SELECT
    l.city,
    ROUND(SUM(f.`Price (INR)`), 2) AS Total_Revenue_INR
FROM fact_swiggy_orders f
JOIN dim_location l
    ON f.location_id = l.location_id
GROUP BY l.city
ORDER BY Total_Revenue_INR DESC
LIMIT 10;

-- Revenue Contribution by State (Absolute Revenue)
SELECT
    l.state,
    ROUND(SUM(f.`Price (INR)`), 2) AS Total_Revenue_INR
FROM fact_swiggy_orders f
JOIN dim_location l
    ON f.location_id = l.location_id
GROUP BY l.state
ORDER BY Total_Revenue_INR DESC;

-- Top 10 Restaurants by Orders
SELECT
    r.restaurant_name,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON f.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY Total_Orders DESC
LIMIT 10;

-- Top 10 Categories by Order Volume

SELECT
    c.category,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_category c
    ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY Total_Orders DESC
LIMIT 10;

-- Most Ordered Dishes

SELECT
    di.Dish_Name,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_dish di
    ON f.dish_id = di.dish_id
GROUP BY di.Dish_Name
ORDER BY Total_Orders DESC;

-- Cuisine Performance (Orders + Avg Rating)

SELECT
    c.category AS Cuisine,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(f.Rating), 2) AS Avg_Rating
FROM fact_swiggy_orders f
JOIN dim_category c
    ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY Total_Orders DESC;

-- Total Orders by Price Range

SELECT
    CASE
        WHEN `Price (INR)` < 100 THEN 'Below 100'
        WHEN `Price (INR)` BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN `Price (INR)` BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN `Price (INR)` BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500 and Above'
    END AS Price_Range,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders
GROUP BY Price_Range
ORDER BY Total_Orders DESC;

-- Rating Distribution (1 to 5)

SELECT
    Rating,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders
WHERE Rating BETWEEN 1 AND 5
GROUP BY Rating
ORDER BY Rating;


