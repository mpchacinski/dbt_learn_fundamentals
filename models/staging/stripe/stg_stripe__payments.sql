{{ config(
    materialized='table'
) }}

with raw_payments as (
    select * from {{ source('stripe', 'payments') }} 
)


select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status as payment_status,
    {{ cents_to_dollars('amount') }} as payment_amount,
    created as payment_created_at
from raw_payments
