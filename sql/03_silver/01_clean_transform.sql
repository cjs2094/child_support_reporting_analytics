USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 1. Drop existing Silver tables before rebuilding
-- =====================================================

DROP TABLE IF EXISTS silver.cases;
DROP TABLE IF EXISTS silver.obligations;
DROP TABLE IF EXISTS silver.acts_payments;
DROP TABLE IF EXISTS silver.csdw_payments;
DROP TABLE IF EXISTS silver.monthly_support;
DROP TABLE IF EXISTS silver.arrears_summary;
GO


-- =====================================================
-- 2. Clean and transform case master data
-- =====================================================

SELECT
    NULLIF(TRIM(case_id), '') AS case_id,
    NULLIF(TRIM(county_code), '') AS county_code,
    NULLIF(TRIM(county), '') AS county,
    NULLIF(UPPER(TRIM(case_status)), '') AS case_status,
    TRY_CONVERT(date, NULLIF(TRIM(open_date), '')) AS open_date
INTO silver.cases
FROM bronze.cases_raw;
GO


-- =====================================================
-- 3. Clean and transform support obligation data
-- =====================================================

SELECT
    NULLIF(TRIM(obligation_id), '') AS obligation_id,
    NULLIF(TRIM(case_id), '') AS case_id,
    TRY_CONVERT(date, NULLIF(TRIM(obligation_month), '')) AS obligation_month,
    NULLIF(UPPER(TRIM(obligation_type)), '') AS obligation_type,
    TRY_CONVERT(decimal(12,2), NULLIF(TRIM(amount_due), '')) AS amount_due
INTO silver.obligations
FROM bronze.obligations_raw;
GO


-- =====================================================
-- 4. Clean and transform ACTS source payment data
-- =====================================================

SELECT
    NULLIF(TRIM(payment_id), '') AS payment_id,
    NULLIF(TRIM(case_id), '') AS case_id,
    NULLIF(TRIM(county_code), '') AS county_code,
    NULLIF(TRIM(county), '') AS county,
    TRY_CONVERT(date, NULLIF(TRIM(payment_date), '')) AS payment_date,
    NULLIF(UPPER(TRIM(payment_type)), '') AS payment_type,
    TRY_CONVERT(decimal(12,2), NULLIF(TRIM(amount), '')) AS amount,
    NULLIF(TRIM(obligation_id), '') AS obligation_id
INTO silver.acts_payments
FROM bronze.acts_payments_raw;
GO


-- =====================================================
-- 5. Clean and transform CSDW warehouse payment data
-- =====================================================

SELECT
    NULLIF(TRIM(payment_id), '') AS payment_id,
    NULLIF(TRIM(case_id), '') AS case_id,
    NULLIF(TRIM(county_code), '') AS county_code,
    NULLIF(TRIM(county), '') AS county,
    TRY_CONVERT(date, NULLIF(TRIM(payment_date), '')) AS payment_date,
    NULLIF(UPPER(TRIM(payment_type)), '') AS payment_type,
    TRY_CONVERT(decimal(12,2), NULLIF(TRIM(amount), '')) AS amount,
    NULLIF(TRIM(obligation_id), '') AS obligation_id
INTO silver.csdw_payments
FROM bronze.csdw_payments_raw;
GO


-- =====================================================
-- 6. Clean and transform monthly support reporting data
-- =====================================================

SELECT
    NULLIF(TRIM(case_id), '') AS case_id,
    TRY_CONVERT(date, NULLIF(TRIM(report_month), '')) AS report_month,
    TRY_CONVERT(decimal(12,2), NULLIF(TRIM(current_due), '')) AS current_due,
    TRY_CONVERT(decimal(12,2), NULLIF(TRIM(current_collected), '')) AS current_collected
INTO silver.monthly_support
FROM bronze.monthly_support_raw;
GO


-- =====================================================
-- 7. Clean and transform arrears summary data
-- =====================================================

SELECT
    NULLIF(TRIM(case_id), '') AS case_id,
    TRY_CONVERT(int, NULLIF(TRIM(fiscal_year), '')) AS fiscal_year,
    TRY_CONVERT(decimal(12,2), NULLIF(TRIM(arrears_balance), '')) AS arrears_balance,
    TRY_CONVERT(decimal(12,2), NULLIF(TRIM(arrears_collected), '')) AS arrears_collected
INTO silver.arrears_summary
FROM bronze.arrears_summary_raw;
GO

