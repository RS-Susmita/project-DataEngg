SELECT
    customer,
    total_orders,
    total_sales,
    avg_order_value,
    CASE
        WHEN total_sales >= 70000 THEN 'High Value'
        WHEN total_sales >= 30000 AND total_sales < 70000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment

FROM {{ ref('customer_sales') }}
ORDER BY total_sales DESC
