
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select transaction_id
from "dev"."main"."stg_coffee_sales"
where transaction_id is null



  
  
      
    ) dbt_internal_test