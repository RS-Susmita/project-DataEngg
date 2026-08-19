
    
    

select
    datetime as unique_field,
    count(*) as n_records

from "dev"."main"."stg_coffee_sales"
where datetime is not null
group by datetime
having count(*) > 1


