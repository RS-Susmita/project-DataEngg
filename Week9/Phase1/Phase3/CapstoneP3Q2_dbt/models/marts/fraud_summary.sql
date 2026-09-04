{{ config(materialized='table') }}

SELECT 
    tx_date,
    COUNTRY,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_flagged_fraud = 1 THEN 1 ELSE 0 END) AS total_flagged_alerts,
    ROUND((SUM(CASE WHEN is_flagged_fraud = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS group_fraud_rate_pct,
    SUM(CASE WHEN is_flagged_fraud = 1 THEN TRANSACTION_AMOUNT ELSE 0 END) AS total_financial_risk_exposure
FROM {{ ref('fraud_alerts') }}
GROUP BY tx_date, COUNTRY
ORDER BY tx_date DESC, total_financial_risk_exposure DESC
