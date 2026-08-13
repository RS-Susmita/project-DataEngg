with source as (
    select * from RETAIL_DB_SR.RAW.raw_customers
),
 
renamed as (
    select
        customer_id,
        customer_name,
        signup_date::date as signup_date
    from source
)
 
select * from renamed