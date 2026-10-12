-- Fixture contains TX002 amount mismatch, TX003 product-only, TX004 and TX006 ledger-only.
-- Only applies to default 2026-09-30 cutoff.
{% if var('as_of_date', '2026-09-30') == '2026-09-30' %}
select 1 as failure where (select count(*) from {{ ref('fct_reconciliation_exceptions') }}) <> 4
{% else %}
select 1 where false
{% endif %}
