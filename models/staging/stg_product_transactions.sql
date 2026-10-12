with ranked as (
    select
        transaction_id, customer_id, cast(amount as numeric(18,2)) as amount,
        currency, lower(status) as status, cast(event_at as timestamp) as event_at,
        row_number() over (partition by transaction_id order by cast(updated_at as timestamp) desc, cast(record_id as integer) desc) as rn
    from {{ ref('product_transactions') }}
    where cast(event_at as timestamp) < (cast('{{ var("as_of_date", "2026-09-30") }}' as date) + interval '1 day')
)
select transaction_id, customer_id, amount, currency, status, event_at
from ranked where rn = 1
