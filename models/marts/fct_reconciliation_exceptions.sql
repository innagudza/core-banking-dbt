with product as (
    select * from {{ ref('stg_product_transactions') }} where status = 'completed'
), ledger as (
    select * from {{ ref('stg_ledger_entries') }} where status = 'posted'
), matched as (
    select coalesce(p.transaction_id,l.transaction_id) as transaction_id,
           p.amount as product_amount, l.amount as ledger_amount,
           p.currency as product_currency, l.currency as ledger_currency,
           case
             when p.transaction_id is null then 'ledger_only'
             when l.transaction_id is null then 'product_only'
             when p.currency is distinct from l.currency then 'currency_mismatch'
             when p.amount is distinct from l.amount then 'amount_mismatch'
             else 'matched' end as reconciliation_status
    from product p full outer join ledger l using (transaction_id)
)
select * from matched where reconciliation_status <> 'matched'
