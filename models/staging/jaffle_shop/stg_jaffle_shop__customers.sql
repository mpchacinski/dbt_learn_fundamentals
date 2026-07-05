with raw_customers as (
    select * from {{ source('jaffle_shop', 'customers') }} 
)

select
    id as customer_id,
    first_name,
    last_name,
    first_name || ' ' || last_name as full_name      
from raw_customers