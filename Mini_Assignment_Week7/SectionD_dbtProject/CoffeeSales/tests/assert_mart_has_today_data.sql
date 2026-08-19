-- tests/assert_mart_has_today_data.sql
-- DuckDB syntax to check if today's date exists in the table
with today_data as (
    select count(*) as row_count
    from {{ ref('daily_revenue.sql') }}
    where date_column = current_date
)

select * 
from today_data 
where row_count = 0
