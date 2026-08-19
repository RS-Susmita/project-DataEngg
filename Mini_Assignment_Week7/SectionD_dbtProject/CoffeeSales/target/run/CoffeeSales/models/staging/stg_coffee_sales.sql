
  
  create view "dev"."main"."stg_coffee_sales__dbt_tmp" as (
    select
    *
from "dev"."main"."coffee_sales"
  );
