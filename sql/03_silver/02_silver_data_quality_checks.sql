USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 1. Check for missing required IDs
-- Verify that required business keys are not NULL.
-- Expected result: issue_count = 0 for all tables
-- =====================================================

-- Check for missing case IDs
SELECT
    'cases' AS table_name,
    'case_id' AS column_name,
    COUNT(*) AS issue_count
FROM silver.cases
WHERE case_id IS NULL

UNION ALL

-- Check for missing obligation IDs
SELECT
    'obligations',
    'obligation_id',
    COUNT(*)
FROM silver.obligations
WHERE obligation_id IS NULL

UNION ALL

-- Check for missing ACTS payment IDs
SELECT
    'acts_payments',
    'payment_id',
    COUNT(*)
FROM silver.acts_payments
WHERE payment_id IS NULL

UNION ALL

-- Check for missing CSDW payment IDs
SELECT
    'csdw_payments',
    'payment_id',
    COUNT(*)
FROM silver.csdw_payments
WHERE payment_id IS NULL;
GO


-- =====================================================
-- 2. Check for numeric conversion failures
-- Verify that non-empty Bronze numeric values can be
-- successfully converted to DECIMAL.
-- Expected result: 0 rows
-- =====================================================

-- Check whether obligation amounts contain non-numeric values
SELECT
    obligation_id,
    case_id,
    amount_due
FROM bronze.obligations_raw
WHERE NULLIF(TRIM(amount_due), '') IS NOT NULL
  AND TRY_CONVERT(decimal(12,2), TRIM(amount_due)) IS NULL;
GO


-- Check whether ACTS payment amounts contain non-numeric values
SELECT
    payment_id,
    case_id,
    amount
FROM bronze.acts_payments_raw
WHERE NULLIF(TRIM(amount), '') IS NOT NULL
  AND TRY_CONVERT(decimal(12,2), TRIM(amount)) IS NULL;
GO


-- Check whether CSDW payment amounts contain non-numeric values
SELECT
    payment_id,
    case_id,
    amount
FROM bronze.csdw_payments_raw
WHERE NULLIF(TRIM(amount), '') IS NOT NULL
  AND TRY_CONVERT(decimal(12,2), TRIM(amount)) IS NULL;
GO


-- =====================================================
-- 3. Check for date conversion failures
-- Verify that non-empty Bronze date values can be
-- successfully converted to DATE.
-- Expected result: 0 rows
-- =====================================================

-- Check whether case open dates contain invalid date values
SELECT
    case_id,
    open_date
FROM bronze.cases_raw
WHERE NULLIF(TRIM(open_date), '') IS NOT NULL
  AND TRY_CONVERT(date, TRIM(open_date)) IS NULL;
GO


-- Check whether obligation months contain invalid date values
SELECT
    obligation_id,
    case_id,
    obligation_month
FROM bronze.obligations_raw
WHERE NULLIF(TRIM(obligation_month), '') IS NOT NULL
  AND TRY_CONVERT(date, TRIM(obligation_month)) IS NULL;
GO


-- Check whether ACTS payment dates contain invalid date values
SELECT
    payment_id,
    case_id,
    payment_date
FROM bronze.acts_payments_raw
WHERE NULLIF(TRIM(payment_date), '') IS NOT NULL
  AND TRY_CONVERT(date, TRIM(payment_date)) IS NULL;
GO


-- =====================================================
-- 4. Check for duplicate business keys
-- Verify that business key values uniquely identify records.
-- Expected result: 0 rows
-- =====================================================

-- Check for duplicate obligation IDs
SELECT
    obligation_id,
    COUNT(*) AS row_count
FROM silver.obligations
GROUP BY obligation_id
HAVING COUNT(*) > 1;
GO


-- Check for duplicate ACTS payment IDs
SELECT
    payment_id,
    COUNT(*) AS row_count
FROM silver.acts_payments
GROUP BY payment_id
HAVING COUNT(*) > 1;
GO


-- =====================================================
-- 5. Check for invalid negative amounts
-- Financial amounts should not contain negative values.
-- Expected result: 0 rows
-- =====================================================

-- Check for negative obligation amounts
SELECT *
FROM silver.obligations
WHERE amount_due < 0;
GO


-- Check for negative ACTS payment amounts
SELECT *
FROM silver.acts_payments
WHERE amount < 0;
GO


-- Check for negative monthly support amounts
SELECT *
FROM silver.monthly_support
WHERE current_due < 0
   OR current_collected < 0;
GO


-- Check for negative arrears balances or collections
SELECT *
FROM silver.arrears_summary
WHERE arrears_balance < 0
   OR arrears_collected < 0;
GO


-- =====================================================
-- 6. Check for invalid categorical values
-- Verify that standardized categorical fields contain
-- only approved domain values.
-- Expected result: 0 rows
-- =====================================================

-- Check for invalid or missing case status values
SELECT DISTINCT
    case_status
FROM silver.cases
WHERE case_status IS NULL
   OR case_status NOT IN ('ACTIVE', 'CLOSED');
GO


-- Check for invalid or missing obligation types
SELECT DISTINCT
    obligation_type
FROM silver.obligations
WHERE obligation_type IS NULL
   OR obligation_type NOT IN ('CURRENT');
GO


-- Check for invalid or missing ACTS payment types
SELECT DISTINCT
    payment_type
FROM silver.acts_payments
WHERE payment_type IS NULL
   OR payment_type NOT IN ('CURRENT', 'ARREARS');
GO


-- =====================================================
-- 7. Check referential integrity between cases
-- and related Silver tables
-- Verify that every child record references an existing case.
-- Expected result: 0 rows
-- =====================================================

-- Find obligations that reference a non-existent case
SELECT DISTINCT
    o.case_id
FROM silver.obligations o
LEFT JOIN silver.cases c
    ON o.case_id = c.case_id
WHERE c.case_id IS NULL;
GO


-- Find ACTS payments that reference a non-existent case
SELECT DISTINCT
    p.case_id
FROM silver.acts_payments p
LEFT JOIN silver.cases c
    ON p.case_id = c.case_id
WHERE c.case_id IS NULL;
GO


-- Find monthly support records that reference a non-existent case
SELECT DISTINCT
    m.case_id
FROM silver.monthly_support m
LEFT JOIN silver.cases c
    ON m.case_id = c.case_id
WHERE c.case_id IS NULL;
GO


-- Find arrears records that reference a non-existent case
SELECT DISTINCT
    a.case_id
FROM silver.arrears_summary a
LEFT JOIN silver.cases c
    ON a.case_id = c.case_id
WHERE c.case_id IS NULL;
GO