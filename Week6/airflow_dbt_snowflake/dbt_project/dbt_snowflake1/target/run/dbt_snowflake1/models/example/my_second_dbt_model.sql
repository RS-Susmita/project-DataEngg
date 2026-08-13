
  create or replace   view RETAIL_DB_SR.RAW.my_second_dbt_model
  
  
  
  
  as (
    -- Use the `ref` function to select from other models

select *
from RETAIL_DB_SR.RAW.my_first_dbt_model
where id = 1
  );

