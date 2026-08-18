
  
  create view "dev"."main"."daily_revenue__dbt_tmp" as (
    select
    date,
    sum(money) as total_daily_revenue
from "dev"."main"."stg_coffee_sales"
GROUP by date
ORDER by date
  );
