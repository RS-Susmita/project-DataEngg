

-- Select the BANK_FRAUD database
USE DATABASE BANK_FRAUD;
DESCRIBE TABLE bankfraud;

SELECT 
    -- 1. Total Transactions
    COUNT(*) AS total_transactions,
    
    -- 2. Total Customers
    COUNT(DISTINCT CUSTOMER_ID) AS total_customers,

     -- 3. Total Fraud Transactions
    SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) AS total_fraud_transactions,
    
    -- 4. Fraud Percentage
    ROUND(
        (SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS fraud_percentage

FROM BANKFRAUD;

-----Q2 . Find the top 10 countries by transaction volume.

SELECT 
    COUNTRY,
    COUNT(*) AS transaction_volume
FROM BANKFRAUD
GROUP BY COUNTRY
ORDER BY transaction_volume DESC
LIMIT 10;

------Q3 Find the top 10 cities generating the highest transaction value.

SELECT 
    CITY,
    SUM(TRANSACTION_AMOUNT) AS total_transaction_value  
FROM BANKFRAUD
GROUP BY CITY
ORDER BY total_transaction_value DESC
LIMIT 10;

-----Q4. Generate a complete data profiling report showing:
-----Column Name
-----Distinct Values
-----Null Count


WITH converted_data AS (
    -- This safely constructs the object for every column row-by-row
    SELECT OBJECT_CONSTRUCT_KEEP_NULL(*) AS row_object
    FROM BANKFRAUD
)
SELECT 
    f.key AS column_name,
    COUNT(DISTINCT f.value) AS distinct_values,
    SUM(CASE WHEN f.value IS NULL OR IS_NULL_VALUE(f.value) THEN 1 ELSE 0 END) AS null_count
FROM converted_data,
LATERAL FLATTEN(input => row_object) f
GROUP BY f.key
ORDER BY column_name ASC;



--------Q5. Determine the percentage distribution of transactions by:
 ----  • Payment Method 
 ----  • Device Type 
 ----  • Merchant Category 

SELECT 
    PAYMENT_METHOD,
    COUNT(*) AS transaction_count,
    ROUND(RATIO_TO_REPORT(transaction_count) OVER () * 100, 2) AS percentage_distribution
FROM BANKFRAUD
GROUP BY PAYMENT_METHOD
ORDER BY transaction_count DESC;


SELECT 
    DEVICE_TYPE,
    COUNT(*) AS transaction_count,
    ROUND(RATIO_TO_REPORT(transaction_count) OVER () * 100, 2) AS percentage_distribution
FROM BANKFRAUD
GROUP BY DEVICE_TYPE
ORDER BY transaction_count DESC;



SELECT 
    MERCHANT_CATEGORY,
    COUNT(*) AS transaction_count,
    ROUND(RATIO_TO_REPORT(transaction_count) OVER () * 100, 2) AS percentage_distribution
FROM BANKFRAUD
GROUP BY MERCHANT_CATEGORY
ORDER BY transaction_count DESC;




----------------Module 2: Customer Behavior Analytics-------------------------

------Q6. Identify the top 20 customers by:-----

SELECT 
    CUSTOMER_ID,
    SUM(TRANSACTION_AMOUNT) AS total_spent
FROM BANKFRAUD
GROUP BY CUSTOMER_ID
ORDER BY total_spent DESC
LIMIT 20;



------Q7. Calculate average transaction amount by age group:----



SELECT 
    CASE 
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        WHEN customer_age BETWEEN 51 AND 65 THEN '51-65'
        WHEN customer_age > 65 THEN '65+'
        ELSE 'Unknown'
END AS Customer_Age,
    ROUND(AVG(TRANSACTION_AMOUNT), 2) AS avg_transaction_amount
FROM BANKFRAUD
GROUP BY Customer_Age
ORDER BY MIN(Customer_Age) ASC;


----Q8. Determine which age group has the highest fraud rate.

SELECT 
    CASE 
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        WHEN customer_age BETWEEN 51 AND 65 THEN '51-65'
        WHEN customer_age> 65 THEN '65+'
        END AS age_group,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND((SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS fraud_rate_pct
FROM BANKFRAUD
GROUP BY age_group
ORDER BY fraud_rate_pct DESC
LIMIT 5;


USE DATABASE BANK_FRAUD;

SELECT 
    CUSTOMER_ID,
    MAX(ACCOUNT_BALANCE) AS current_balance,
    COUNT(*) AS total_transactions,
    -- Assumes TRANSACTION_DATE is parsed as a true date or timestamp
    DATEDIFF('day', MAX(TO_DATE(TRANSACTION_DATE, 'DD-MM-YYYY')), CURRENT_DATE()) AS days_since_last_transaction
FROM BANKFRAUD
GROUP BY CUSTOMER_ID
HAVING 
    MAX(ACCOUNT_BALANCE) > 50000          -- 1. High Balance threshold
    AND COUNT(*) < 5                       -- 2. Low Transaction Frequency
    AND days_since_last_transaction > 90   -- 3. Potential Dormant (No activity in 90+ days)
ORDER BY current_balance DESC;

----Q9. Find customers with:
-----   1. High Balance
---- 2. Low Transaction Frequency
----  3. Potential dormant accounts.



SELECT 
    CUSTOMER_ID,
    MAX(ACCOUNT_BALANCE) AS current_balance,
    COUNT(*) AS total_transactions,
    -- Assumes TRANSACTION_DATE is parsed as a true date or timestamp
    DATEDIFF('day', MAX(TO_DATE(TRANSACTION_DATE, 'DD-MM-YYYY')), CURRENT_DATE()) AS days_since_last_transaction
FROM BANKFRAUD
GROUP BY CUSTOMER_ID
HAVING 
    MAX(ACCOUNT_BALANCE) > 50000          -- 1. High Balance threshold
    AND COUNT(*) < 5                       -- 2. Low Transaction Frequency
    AND days_since_last_transaction > 90   -- 3. Potential Dormant (No activity in 90+ days)

ORDER BY current_balance DESC;


-----Q10. Calculate average account balance and credit score by country.


SELECT 
    COUNTRY,
    ROUND(AVG(ACCOUNT_BALANCE), 2) AS avg_account_balance,
    ROUND(AVG(CREDIT_SCORE), 2) AS avg_credit_score
FROM BANKFRAUD
GROUP BY COUNTRY
ORDER BY avg_account_balance DESC;



-- Q11: Fraud Rate by Merchant Category
SELECT 
    MERCHANT_CATEGORY,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND((SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS fraud_rate_pct
FROM BANKFRAUD
GROUP BY MERCHANT_CATEGORY
ORDER BY fraud_rate_pct DESC;



-- Q12: Fraud Rate by Payment Method
SELECT 
    PAYMENT_METHOD,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND((SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS fraud_rate_pct
FROM BANKFRAUD
GROUP BY PAYMENT_METHOD
ORDER BY fraud_rate_pct DESC;



-- Q13: Fraud Rate by Device Type
SELECT 
    DEVICE_TYPE,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND((SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS fraud_rate_pct
FROM BANKFRAUD
GROUP BY DEVICE_TYPE
ORDER BY fraud_rate_pct DESC;

------ Find Most Common Fraud Type 
SELECT 
    FRAUD_TYPE,
    COUNT(*) AS fraud_count,
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2) AS percentage_contribution
FROM BANKFRAUD
WHERE IS_FRAUD = 1
GROUP BY FRAUD_TYPE
ORDER BY fraud_count DESC;

USE DATABASE BANK_FRAUD;



SELECT 
    -- 1. Day vs Night Analysis (Combines Date + Time strings to extract the exact hour)
    CASE 
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP(TRANSACTION_DATE || ' ' || TRANSACTION_TIME, 'DD-MM-YYYY HH24:MI:SS')) BETWEEN 6 AND 19 
            THEN 'Day (6AM - 7PM)'
        ELSE 'Night (8PM - 5AM)'
    END AS time_of_day,

    -- 2. Weekend vs Weekday Analysis 
    CASE 
        WHEN DAYOFWEEK(TO_DATE(TRANSACTION_DATE, 'DD-MM-YYYY')) IN (6, 0) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    COUNT(*) AS total_transactions,
    SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND((SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS fraud_rate_pct

FROM BANKFRAUD
GROUP BY time_of_day, day_type
ORDER BY fraud_rate_pct DESC;


SELECT 
    -- 1. Create a combined dimension for the X-axis
    time_of_day || ' - ' || day_type AS combined_time_dimension,
    
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND((SUM(CASE WHEN IS_FRAUD = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS fraud_rate_pct
FROM BANKFRAUD
GROUP BY time_of_day, day_type, combined_time_dimension
ORDER BY fraud_rate_pct DESC;
