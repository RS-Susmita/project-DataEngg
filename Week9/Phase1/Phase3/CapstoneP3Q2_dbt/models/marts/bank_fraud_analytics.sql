{{ config(
    materialized='table',
    post_hook=[
        "CREATE TABLE IF NOT EXISTS {{ this.schema }}.dbt_row_count_log (run_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(), table_name STRING, row_count INT);",
        "INSERT INTO {{ this.schema }}.dbt_row_count_log (table_name, row_count) SELECT '{{ this.name }}', COUNT(*) FROM {{ this }};"
    ]
) }}

WITH raw_data AS (
    SELECT * FROM {{ source('bank_fraud_source', 'BANKFRAUD') }}
)

SELECT 
    CUSTOMER_ID,
    -- Using the unified concatenation code we verified earlier to parse dates and times cleanly
    TO_DATE(TRANSACTION_DATE, 'DD-MM-YYYY') AS tx_date,
    TO_TIME(TRANSACTION_TIME) AS tx_time,
    TO_TIMESTAMP(TRANSACTION_DATE || ' ' || TRANSACTION_TIME, 'DD-MM-YYYY HH24:MI:SS') AS tx_timestamp,
    CITY,
    COUNTRY,
    PAYMENT_METHOD,
    DEVICE_TYPE,
    TRANSACTION_AMOUNT,
    MERCHANT_CATEGORY,
    IS_FRAUD,
    FRAUD_TYPE
FROM raw_data
WHERE TRANSACTION_AMOUNT > 0
