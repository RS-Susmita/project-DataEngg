{{ config(
    materialized='table',
    post_hook=[
        "CREATE TABLE IF NOT EXISTS {{ this.schema }}.dbt_fraud_alert_log (run_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(), alert_count INT);" ,
        "INSERT INTO {{ this.schema }}.dbt_fraud_alert_log (alert_count) SELECT COUNT(*) FROM {{ this }} WHERE is_flagged_fraud = 1;"
    ]
) }}

WITH base_data AS (
    -- Task 1: Load transaction data from our verified pipeline table
    SELECT * FROM {{ ref('bank_fraud_analytics') }}
),

risk_scored_data AS (
    -- Task 2: Apply conditional fraud detection rules using window metrics
    SELECT 
        *,
        -- Rule 1: High Velocity (More than 3 transactions in a row where amount > 800)
        CASE 
            WHEN TRANSACTION_AMOUNT > 800 AND 
                 COUNT(*) OVER (PARTITION BY CUSTOMER_ID ORDER BY tx_timestamp RANGE BETWEEN INTERVAL '1 HOUR' PRECEDING AND CURRENT ROW) >= 3 
                 THEN 1 ELSE 0 
        END AS risk_rule_velocity,

        -- Rule 2: Suspicious Night Activities (High amount spent between 11 PM and 4 AM)
        CASE 
            WHEN TRANSACTION_AMOUNT > 1500 AND EXTRACT(HOUR FROM tx_timestamp) IN (23, 0, 1, 2, 3, 4) 
                 THEN 1 ELSE 0 
        END AS risk_rule_night_spike,

        -- Rule 3: Blacklisted/High-Risk Merchant Categories 
        CASE 
            WHEN MERCHANT_CATEGORY IN ('Online Gambling', 'Crypto Exchange', 'Luxury Goods') AND TRANSACTION_AMOUNT > 500 
                 THEN 1 ELSE 0 
        END AS risk_rule_high_risk_merchant

    FROM base_data
)

-- Task 3: Flag suspicious transactions under a single risk action flag
SELECT 
    CUSTOMER_ID,
    tx_date,
    tx_time,
    tx_timestamp,
    CITY,
    COUNTRY,
    PAYMENT_METHOD,
    DEVICE_TYPE,
    TRANSACTION_AMOUNT,
    FRAUD_TYPE,
    risk_rule_velocity,
    risk_rule_night_spike,
    risk_rule_high_risk_merchant,
    -- If any individual rule fires, or if it was marked fraud historically, flag it as a risk alert
    CASE 
        WHEN IS_FRAUD = 1 OR risk_rule_velocity = 1 OR risk_rule_night_spike = 1 OR risk_rule_high_risk_merchant = 1 
             THEN 1 ELSE 0 
    END AS is_flagged_fraud
FROM risk_scored_data