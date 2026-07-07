{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='order_id',
        on_schema_change='sync_all_columns'

    )
}}

with payments as (
    
    select
        order_id,
        sum(case when payment_status = 'success' then payment_amount end) as amount
    from {{ ref('stg_stripe__payments') }}
    group by order_id

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

final as (
    
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        coalesce(payments.amount, 0) as amount

    from orders

    left join payments 
        on orders.order_id = payments.order_id

)

select * from final
{% if is_incremental() %}
    where final.order_date > (select max(order_date) from {{ this }})
{% endif %}