-- Import CTEs

with customers as (
    select * from {{ ref('stg_jaffle_shop__customers') }} 
),
orders as (
    select * from {{ ref('int_orders') }} 
    where payment_status != 'fail'
),


customer_order_history as (

    select
        customers.customer_id,
        customers.full_name,
        customers.last_name,
        customers.first_name,
        min(order_date) as first_order_date,
        min(orders.valid_order_date) as first_non_returned_order_date,
        max(orders.valid_order_date) as most_recent_non_returned_order_date,
        coalesce(max(user_order_seq), 0) as order_count,
        coalesce(count(case when orders.order_status != 'returned' then 1 end),0) as non_returned_order_count,

        sum(
            case 
                when orders.valid_order_date is not null
                then orders.order_value_dollars
                else 0 
            end) as total_lifetime_value,

        {{ function('safe_divide') }}(
            sum(
                case 
                    when orders.valid_order_date is not null
                    then orders.order_value_dollars
                    else 0 
                end),
                count(case when orders.valid_order_date is not null then 1 end)
        ) as avg_non_returned_order_value,

        array_agg(distinct orders.order_id) as order_ids

    from orders

    join customers
    on orders.customer_id = customers.customer_id 

    where orders.order_status not in ('pending') 

    group by customers.customer_id, customers.full_name, customers.last_name, customers.first_name

),

-- Final CTE
final as (

    select
        orders.order_id,
        orders.customer_id,
        customers.last_name,
        customers.first_name,
        customer_order_history.first_order_date,
        customer_order_history.order_count,
        customer_order_history.total_lifetime_value,
        orders.order_value_dollars,
        orders.order_status,
        orders.payment_status
    from orders

    join customers
    on orders.customer_id = customers.customer_id

    join customer_order_history
    on orders.customer_id = customer_order_history.customer_id

)

-- Final select
select * from final