# SQL Run Order

Run the scripts in this order in SSMS. The folder numbers reflect dependency order.

1. `01_setup/01_create_database.sql`
2. `01_setup/02_create_bronze_tables.sql`
3. Edit the local CSV folder in `02_bronze/01_bulk_load_template.sql`, then run it.
4. `03_silver/01_clean_transform.sql`
5. `03_silver/02_silver_data_quality_checks.sql`
6. `04_gold/01_build_dimensions.sql`
7. `04_gold/02_build_fact_tables.sql`
8. Run all scripts in `05_quality/` in numeric order.
9. Run all scripts in `06_mart/` in numeric order.
10. Run all scripts in `07_reporting/` in numeric order.
11. `08_validation/01_numeric_lineage_validation.sql`

## Layer responsibilities

- **01_setup**: database and schema creation.
- **02_bronze**: raw CSV ingestion.
- **03_silver**: cleaning, standardization, and Silver-layer DQ checks.
- **04_gold**: dimensional model (`dim_*` and `fact_*`).
- **05_quality**: ACTS-to-CSDW reconciliation, duplicate detection, and DQ summaries.
- **06_mart**: reusable analytics-ready views for reporting.
- **07_reporting**: business KPI, county performance, and trend queries.
- **08_validation**: end-to-end numeric lineage validation.

The numeric lineage validation queries should return **0 rows** when source-level calculations match the corresponding reporting totals.
