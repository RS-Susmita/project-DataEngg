

with source as (

    select * from RETAIL_DB_SR.RAW.raw_products

),

renamed as (

    select
        product_id,
        product_name as product_title,
        category,
        cast(price as decimal(10,2)) as product_price

    from source

)

select * from renamed