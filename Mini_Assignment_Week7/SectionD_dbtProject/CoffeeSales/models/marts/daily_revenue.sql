select
    date,
    sum(money) as total_daily_revenue
from {{ ref('stg_coffee_sales') }}
GROUP by date
ORDER by date