# Data Lineage

1. `cases.csv`: case master.
2. `obligations.csv`: CURRENT amount due at case-month grain.
3. `acts_payments.csv`: transaction-level collections.
4. `monthly_support.csv`: derived from obligations and ACTS CURRENT payments.
5. `csdw_payments.csv`: simulated ACTS transfer with deliberate DQ defects.
6. `payment_reconciliation_expected.csv`: expected source-target comparison result.

The monthly KPI input is therefore traceable back to transaction-level source data.
