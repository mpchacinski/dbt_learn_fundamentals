    select
        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status,
        amount / 100 as amount,
        created as created_at

    from DATAEXPERT_STUDENT.MPCHACINSKI11351.raw_stripe_payments