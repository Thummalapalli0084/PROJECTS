-- ============================================================
-- Credit Card Fraud Detection — Complete SQL Project
-- Author  : Dinesh Naidu Thummalapalli
-- Dataset : credit_card_fraud_10k (10,000 transactions)
-- Tool    : MySQL Workbench
-- HOW TO RUN: Open this file in MySQL Workbench and run
--             each section one by one (Ctrl+Enter)
-- ============================================================


-- ============================================================
-- STEP 1: CREATE & SELECT DATABASE
-- ============================================================

DROP DATABASE IF EXISTS fraud_detection;
CREATE DATABASE fraud_detection;
USE fraud_detection;


-- ============================================================
-- STEP 2: CREATE TABLE
-- ============================================================

CREATE TABLE credit_card_transactions (
    transaction_id       INT            PRIMARY KEY,
    amount               DECIMAL(10,2),
    transaction_hour     INT,
    merchant_category    VARCHAR(50),
    foreign_transaction  TINYINT,
    location_mismatch    TINYINT,
    device_trust_score   INT,
    velocity_last_24h    INT,
    cardholder_age       INT,
    is_fraud             TINYINT
);


-- ============================================================
-- STEP 3: LOAD CSV DATA
-- NOTE: Update the file path below if your file is in a
--       different location
-- ============================================================

LOAD DATA INFILE 'C:/Users/krish/Downloads/archive (8)/credit_card_fraud_10k.csv'
INTO TABLE credit_card_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- STEP 4: VERIFY DATA LOADED CORRECTLY
-- ============================================================

SELECT COUNT(*) AS total_rows FROM credit_card_transactions;
-- Expected: 10000

SELECT * FROM credit_card_transactions LIMIT 10;


-- ============================================================
-- SECTION 1: OVERVIEW & DATA QUALITY
-- ============================================================

-- Q1.1: Overall fraud summary
SELECT
    COUNT(*)                                            AS total_transactions,
    SUM(is_fraud)                                       AS fraud_transactions,
    COUNT(*) - SUM(is_fraud)                            AS legit_transactions,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)         AS fraud_rate_pct,
    ROUND(SUM(amount), 2)                               AS total_transaction_value,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amount END), 2) AS total_fraud_value
FROM credit_card_transactions;

-- Q1.2: Check for null values
SELECT
    SUM(CASE WHEN transaction_id      IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN amount              IS NULL THEN 1 ELSE 0 END) AS null_amount,
    SUM(CASE WHEN transaction_hour    IS NULL THEN 1 ELSE 0 END) AS null_hour,
    SUM(CASE WHEN merchant_category   IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN foreign_transaction IS NULL THEN 1 ELSE 0 END) AS null_foreign,
    SUM(CASE WHEN location_mismatch   IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN device_trust_score  IS NULL THEN 1 ELSE 0 END) AS null_device_score,
    SUM(CASE WHEN velocity_last_24h   IS NULL THEN 1 ELSE 0 END) AS null_velocity,
    SUM(CASE WHEN cardholder_age      IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN is_fraud            IS NULL THEN 1 ELSE 0 END) AS null_is_fraud
FROM credit_card_transactions;

-- Q1.3: Descriptive statistics for transaction amount
SELECT
    ROUND(AVG(amount), 2)                                       AS avg_amount,
    ROUND(MIN(amount), 2)                                       AS min_amount,
    ROUND(MAX(amount), 2)                                       AS max_amount,
    ROUND(STDDEV(amount), 2)                                    AS std_amount,
    ROUND(AVG(CASE WHEN is_fraud = 1 THEN amount END), 2)      AS avg_fraud_amount,
    ROUND(AVG(CASE WHEN is_fraud = 0 THEN amount END), 2)      AS avg_legit_amount
FROM credit_card_transactions;


-- ============================================================
-- SECTION 2: FRAUD BY MERCHANT CATEGORY
-- ============================================================

-- Q2.1: Fraud rate per merchant category
SELECT
    merchant_category,
    COUNT(*)                                            AS total_transactions,
    SUM(is_fraud)                                       AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)         AS fraud_rate_pct,
    ROUND(AVG(amount), 2)                               AS avg_transaction_amount,
    ROUND(SUM(CASE WHEN is_fraud=1 THEN amount END), 2) AS total_fraud_amount
FROM credit_card_transactions
GROUP BY merchant_category
ORDER BY fraud_rate_pct DESC;

-- Q2.2: Top 20 highest value fraud transactions
SELECT
    transaction_id,
    merchant_category,
    amount,
    transaction_hour,
    foreign_transaction,
    location_mismatch,
    device_trust_score
FROM credit_card_transactions
WHERE is_fraud = 1
ORDER BY amount DESC
LIMIT 20;


-- ============================================================
-- SECTION 3: TIME-BASED FRAUD ANALYSIS
-- ============================================================

-- Q3.1: Fraud rate by hour of day
SELECT
    transaction_hour,
    COUNT(*)                                            AS total_transactions,
    SUM(is_fraud)                                       AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)         AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY transaction_hour
ORDER BY transaction_hour;

-- Q3.2: Fraud rate by time bucket
SELECT
    CASE
        WHEN transaction_hour BETWEEN 0  AND 5  THEN 'Night (0-5 AM)'
        WHEN transaction_hour BETWEEN 6  AND 11 THEN 'Morning (6-11 AM)'
        WHEN transaction_hour BETWEEN 12 AND 17 THEN 'Afternoon (12-5 PM)'
        ELSE                                          'Evening (6-11 PM)'
    END                                                AS time_bucket,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct,
    ROUND(AVG(amount), 2)                              AS avg_amount
FROM credit_card_transactions
GROUP BY time_bucket
ORDER BY fraud_rate_pct DESC;

-- Q3.3: Top 5 peak fraud hours
SELECT
    transaction_hour,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY transaction_hour
ORDER BY fraud_rate_pct DESC
LIMIT 5;


-- ============================================================
-- SECTION 4: RISK FLAG ANALYSIS
-- ============================================================

-- Q4.1: Fraud rate — foreign vs domestic
SELECT
    CASE WHEN foreign_transaction = 1 THEN 'Foreign' ELSE 'Domestic' END AS transaction_type,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY foreign_transaction
ORDER BY fraud_rate_pct DESC;

-- Q4.2: Fraud rate — location mismatch
SELECT
    CASE WHEN location_mismatch = 1 THEN 'Location Mismatch' ELSE 'Location Matched' END AS location_status,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY location_mismatch
ORDER BY fraud_rate_pct DESC;

-- Q4.3: Combined risk flag segmentation
SELECT
    CASE
        WHEN foreign_transaction = 1 AND location_mismatch = 1 THEN 'Foreign + Location Mismatch'
        WHEN foreign_transaction = 1 AND location_mismatch = 0 THEN 'Foreign Only'
        WHEN foreign_transaction = 0 AND location_mismatch = 1 THEN 'Location Mismatch Only'
        ELSE                                                         'No Flags'
    END                                                AS risk_segment,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct,
    ROUND(AVG(amount), 2)                              AS avg_amount
FROM credit_card_transactions
GROUP BY risk_segment
ORDER BY fraud_rate_pct DESC;


-- ============================================================
-- SECTION 5: DEVICE TRUST & VELOCITY ANALYSIS
-- ============================================================

-- Q5.1: Avg device trust score — fraud vs legitimate
SELECT
    CASE WHEN is_fraud = 1 THEN 'Fraud' ELSE 'Legitimate' END AS transaction_type,
    ROUND(AVG(device_trust_score), 2)                  AS avg_device_trust_score,
    ROUND(MIN(device_trust_score), 2)                  AS min_score,
    ROUND(MAX(device_trust_score), 2)                  AS max_score,
    COUNT(*)                                           AS total_count
FROM credit_card_transactions
GROUP BY is_fraud;

-- Q5.2: Fraud rate by device trust score bucket
SELECT
    CASE
        WHEN device_trust_score < 20  THEN 'Very Low (0-19)'
        WHEN device_trust_score < 40  THEN 'Low (20-39)'
        WHEN device_trust_score < 60  THEN 'Medium (40-59)'
        WHEN device_trust_score < 80  THEN 'High (60-79)'
        ELSE                               'Very High (80-100)'
    END                                                AS trust_bucket,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY trust_bucket
ORDER BY fraud_rate_pct DESC;

-- Q5.3: Fraud rate by transaction velocity
SELECT
    velocity_last_24h,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY velocity_last_24h
ORDER BY velocity_last_24h;

-- Q5.4: High velocity transactions (5+ in 24h)
SELECT
    COUNT(*)                                           AS high_velocity_count,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
WHERE velocity_last_24h >= 5;


-- ============================================================
-- SECTION 6: CARDHOLDER AGE ANALYSIS
-- ============================================================

-- Q6.1: Fraud rate by age group
SELECT
    CASE
        WHEN cardholder_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN cardholder_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN cardholder_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN cardholder_age BETWEEN 46 AND 55 THEN '46-55'
        ELSE                                        '56-69'
    END                                                AS age_group,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct,
    ROUND(AVG(amount), 2)                              AS avg_amount
FROM credit_card_transactions
GROUP BY age_group
ORDER BY fraud_rate_pct DESC;


-- ============================================================
-- SECTION 7: MERCHANT × TIME CROSS ANALYSIS
-- ============================================================

-- Q7.1: Fraud rate by merchant category and time bucket
SELECT
    merchant_category,
    CASE
        WHEN transaction_hour BETWEEN 0  AND 5  THEN 'Night'
        WHEN transaction_hour BETWEEN 6  AND 11 THEN 'Morning'
        WHEN transaction_hour BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE                                          'Evening'
    END                                                AS time_bucket,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY merchant_category, time_bucket
ORDER BY fraud_rate_pct DESC;


-- ============================================================
-- SECTION 8: COMPOSITE RISK SCORING
-- ============================================================

-- Q8.1: High risk transactions (risk score >= 40)
SELECT
    transaction_id,
    amount,
    transaction_hour,
    merchant_category,
    foreign_transaction,
    location_mismatch,
    device_trust_score,
    velocity_last_24h,
    is_fraud,
    (foreign_transaction * 25)
    + (location_mismatch * 25)
    + ROUND((100 - device_trust_score) * 0.3, 0)
    + (velocity_last_24h * 5)                         AS risk_score
FROM credit_card_transactions
WHERE
    (foreign_transaction * 25)
    + (location_mismatch * 25)
    + ROUND((100 - device_trust_score) * 0.3, 0)
    + (velocity_last_24h * 5) >= 40
ORDER BY risk_score DESC
LIMIT 50;

-- Q8.2: Fraud rate by risk segment
SELECT
    CASE
        WHEN (foreign_transaction * 25)
             + (location_mismatch * 25)
             + ROUND((100 - device_trust_score) * 0.3, 0)
             + (velocity_last_24h * 5) >= 40 THEN 'High Risk'
        WHEN (foreign_transaction * 25)
             + (location_mismatch * 25)
             + ROUND((100 - device_trust_score) * 0.3, 0)
             + (velocity_last_24h * 5) >= 20 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END                                                AS risk_flag,
    COUNT(*)                                           AS total_transactions,
    SUM(is_fraud)                                      AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2)        AS fraud_rate_pct
FROM credit_card_transactions
GROUP BY risk_flag
ORDER BY fraud_rate_pct DESC;


-- ============================================================
-- SECTION 9: FINAL ENRICHED VIEW (POWER BI READY)
-- ============================================================

-- Q9.1: Create enriched view with all engineered features
CREATE OR REPLACE VIEW fraud_enriched_view AS
SELECT
    transaction_id,
    amount,
    transaction_hour,
    merchant_category,
    foreign_transaction,
    location_mismatch,
    device_trust_score,
    velocity_last_24h,
    cardholder_age,
    is_fraud,
    -- Time bucket
    CASE
        WHEN transaction_hour BETWEEN 0  AND 5  THEN 'Night (0-5 AM)'
        WHEN transaction_hour BETWEEN 6  AND 11 THEN 'Morning'
        WHEN transaction_hour BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE                                          'Evening'
    END AS hour_bucket,
    -- Age group
    CASE
        WHEN cardholder_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN cardholder_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN cardholder_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN cardholder_age BETWEEN 46 AND 55 THEN '46-55'
        ELSE                                        '56-69'
    END AS age_group,
    -- Amount tier
    CASE
        WHEN amount < 50   THEN 'Low (<$50)'
        WHEN amount < 200  THEN 'Medium ($50-200)'
        WHEN amount < 500  THEN 'High ($200-500)'
        ELSE                    'Very High (>$500)'
    END AS amount_tier,
    -- Composite risk score
    (foreign_transaction * 25)
    + (location_mismatch * 25)
    + ROUND((100 - device_trust_score) * 0.3, 0)
    + (velocity_last_24h * 5)                         AS risk_score,
    -- Risk flag
    CASE
        WHEN (foreign_transaction * 25)
             + (location_mismatch * 25)
             + ROUND((100 - device_trust_score) * 0.3, 0)
             + (velocity_last_24h * 5) >= 40 THEN 'High'
        WHEN (foreign_transaction * 25)
             + (location_mismatch * 25)
             + ROUND((100 - device_trust_score) * 0.3, 0)
             + (velocity_last_24h * 5) >= 20 THEN 'Medium'
        ELSE 'Low'
    END AS risk_flag
FROM credit_card_transactions;

-- Preview the enriched view
SELECT * FROM fraud_enriched_view LIMIT 10;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
