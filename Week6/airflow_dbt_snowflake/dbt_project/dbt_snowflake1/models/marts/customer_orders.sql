with orders as (
    select * from {{ ref('stg_orders') }}
),
 
customers as (
    select * from {{ ref('stg_customers') }}
),
 
joined as (
    select
        c.customer_id,
        c.customer_name,
        c.signup_date,
        count(o.order_id) as total_orders,
        coalesce(sum(o.order_amount), 0) as lifetime_value
    from customers c
    left join orders o on c.customer_id = o.customer_id
    group by 1, 2, 3
)
 
select * from joined