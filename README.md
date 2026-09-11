# Child Support Reporting Analytics — v3 Validated

Synthetic educational portfolio. It does **not** reproduce official NC DHHS ACTS/CSDW schemas or contain real client data.

## Core lineage

```text
obligations.csv
   └─ SUM(amount_due), case + month ─────────────┐
                                                 ├─> monthly_support.csv
acts_payments.csv                                │
   └─ SUM(CURRENT amount), case + month ─────────┘

acts_payments.csv
   └─ simulated transfer ─> csdw_payments.csv
                            + intentional DQ defects
```

`monthly_support.csv` is generated from the source datasets, not independently randomized.

## Required equations

For every case/month:

`current_due = SUM(obligations.amount_due WHERE obligation_type='CURRENT')`

`current_collected = SUM(acts_payments.amount WHERE payment_type='CURRENT')`

## Validation result

See `data/processed/lineage_validation_summary.csv`.
Both rules were programmatically tested across all 1,080 case-month rows before packaging. Expected mismatch count: **0**.

## Intentional ACTS → CSDW defects

August 2026 includes controlled synthetic missing records, amount mismatches, duplicate payment IDs, and CSDW-only records. Those defects are deliberate and are for reconciliation practice.

## SQL portfolio layers

- `04_gold`: dimensional model with case/county/date dimensions and obligation/collection facts.
- `05_quality`: ACTS-to-CSDW reconciliation, duplicate detection, and DQ summary.
- `06_mart`: reusable analytics-ready views for monthly support and arrears analysis.
- `07_reporting`: Current Support KPI, Arrears KPI, county performance, and month-over-month trend.
- `08_validation`: end-to-end numeric lineage tests.

See `docs/SQL_RUN_ORDER.md` before running the project in SSMS.

## Controlled Business Scenarios

The synthetic dataset includes several intentionally designed business scenarios for testing and reporting:

- Full and partial CURRENT support collections
- Zero-payment case-months: `C00001`, `C00002`, and `C00003` have a CURRENT obligation in August 2026 but no CURRENT ACTS payment
- ACTS/CSDW missing-record exceptions
- CSDW amount mismatches
- Duplicate CSDW payment IDs

The zero-payment scenarios are intentionally removed from both ACTS and CSDW payment transactions so they represent true non-payment activity rather than a reconciliation defect. Their `monthly_support.current_collected` value is `0.00`.
