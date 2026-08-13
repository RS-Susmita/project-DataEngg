
  create or replace   view RETAIL_DB_SR.RAW.stg_orders
  
  
  
  
  as (
    with source as (
    select * from RETAIL_DB_SR.RAW.raw_orders
),
 
renamed as (
    select
        order_id,
        customer_id,
        order_date::date as order_date,
        status,
        amount::decimal(10,2) as order_amount
    from source
)
 
select * from renamed
  );

