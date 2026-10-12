# Core Banking Reconciliation — PostgreSQL + dbt

Reconcile product transactions against ledger postings as of an explicit cutoff date.

## Problem

Product and ledger systems ingest at different times and with different statuses. Duplicates, amount mismatches, and late-arriving rows create discrepancies. Reconciliation uses a fixed **as-of** cutoff instead of `CURRENT_TIMESTAMP`.

## Models

```text
seeds (product_transactions, ledger_entries)
        │
        ▼
stg_product_transactions     stg_ledger_entries
        │                           │
        └───────────┬───────────────┘
                    ▼
      fct_reconciliation_exceptions
```

- Grain: `transaction_id`
- Include completed product rows and posted ledger rows with `event_at <= cutoff`
- Latest row per id: `updated_at DESC, record_id DESC`
- Default cutoff: `var('as_of_date', '2026-09-30')`
- Fixture test: `tests/assert_expected_exceptions.sql`

## Stack

PostgreSQL 14+, dbt-core + dbt-postgres. Seed data is synthetic.

## Setup

1. Create database `banking_portfolio`.
2. Install deps:

```bash
cd core_banking_dbt
python -m pip install -r requirements.txt
```

3. Copy `profiles.example.yml` to `~/.dbt/profiles.yml` (Windows: `C:\Users\<You>\.dbt\profiles.yml`). Prefer env vars `PGHOST`, `PGUSER`, `PGPASSWORD` — do not commit real credentials.
4. Run:

```bash
dbt debug
dbt seed
dbt run
dbt test
```

5. Inspect exceptions (schema name may vary):

```sql
select *
from public_marts.fct_reconciliation_exceptions
order by transaction_id;
```

### Another cutoff

```bash
dbt run --vars "{as_of_date: 2026-09-29}"
```

## Structure

```
dbt_project.yml
profiles.example.yml
requirements.txt
seeds/
models/staging/
models/marts/
tests/
```

Teaching sample: one ledger entry per transaction assumed; no FX or full double-entry modeling.
