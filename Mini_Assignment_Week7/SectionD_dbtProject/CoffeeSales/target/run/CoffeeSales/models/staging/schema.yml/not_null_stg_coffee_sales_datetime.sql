
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select datetime
from "dev"."main"."stg_coffee_sales"
where datetime is null



  
  
      
    ) dbt_internal_test