USE ChildSupportReportingPortfolio;
GO

-- =====================================================
-- 01_numeric_lineage_validation.sql
--
-- Purpose:
-- Validate that monthly summary values can be reproduced
-- from detailed Silver-layer records.
--
-- Improvement:
-- FULL OUTER JOIN is used so validation can detect:
--   1. Amount mismatches
--   2. Records missing from monthly_support
--   3. Records missing from detailed source data
--
-- Important:
-- For collections, a monthly_support value of 0 with no
-- ACTS CURRENT payment is valid and should not be flagged.
--
-- Expected result:
--   0 rows for each test.
-- =====================================================


-- =====================================================
-- TEST 1: Validate Current Support Due
--
-- Compare:
--   silver.monthly_support.current_due
--      vs.
--   SUM(silver.obligations.amount_due)
--
-- Grain:
--   One row per case per report month.
--
-- Expected result:
--   0 rows.
-- =====================================================

WITH obligation_monthly AS (
    SELECT
        case_id,
        obligation_month AS report_month,
        SUM(amount_due) AS derived_current_due
    FROM silver.obligations
    WHERE obligation_type = 'CURRENT'
    GROUP BY
        case_id,
        obligation_month
)
SELECT
    COALESCE(m.case_id, o.case_id) AS case_id,
    COALESCE(m.report_month, o.report_month) AS report_month,
    m.current_due AS monthly_support_current_due,
    o.derived_current_due,
    CAST(
        COALESCE(m.current_due, 0)
        - COALESCE(o.derived_current_due, 0)
        AS decimal(12,2)
    ) AS difference,
    CASE
        WHEN m.case_id IS NULL THEN 'MISSING_IN_MONTHLY_SUPPORT'
        WHEN o.case_id IS NULL THEN 'MISSING_IN_OBLIGATIONS'
        ELSE 'AMOUNT_MISMATCH'
    END AS validation_issue
FROM silver.monthly_support m
FULL OUTER JOIN obligation_monthly o
    ON  m.case_id = o.case_id
    AND m.report_month = o.report_month
WHERE
       m.case_id IS NULL
    OR o.case_id IS NULL
    OR ABS(
        COALESCE(m.current_due, 0)
        - COALESCE(o.derived_current_due, 0)
    ) > 0.01
ORDER BY
    report_month,
    case_id;
GO


-- =====================================================
-- TEST 2: Validate Current Support Collected
--
-- Compare:
--   silver.monthly_support.current_collected
--      vs.
--   SUM(silver.acts_payments.amount)
--
-- ACTS payment dates are normalized to the first day
-- of each month to match the monthly_support grain.
--
-- A case-month with current_collected = 0 and no ACTS
-- CURRENT payment is valid. COALESCE treats the missing
-- transaction aggregate as zero for numeric comparison.
--
-- Expected result:
--   0 rows.
-- =====================================================

WITH acts_monthly AS (
    SELECT
        case_id,
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        ) AS report_month,
        SUM(amount) AS derived_current_collected
    FROM silver.acts_payments
    WHERE payment_type = 'CURRENT'
    GROUP BY
        case_id,
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        )
)
SELECT
    COALESCE(m.case_id, a.case_id) AS case_id,
    COALESCE(m.report_month, a.report_month) AS report_month,
    m.current_collected AS monthly_support_current_collected,
    COALESCE(a.derived_current_collected, 0) AS derived_current_collected,
    CAST(
        COALESCE(m.current_collected, 0)
        - COALESCE(a.derived_current_collected, 0)
        AS decimal(12,2)
    ) AS difference,
    CASE
        WHEN m.case_id IS NULL THEN 'MISSING_IN_MONTHLY_SUPPORT'
        WHEN a.case_id IS NULL
             AND COALESCE(m.current_collected, 0) <> 0
            THEN 'MISSING_IN_ACTS'
        ELSE 'AMOUNT_MISMATCH'
    END AS validation_issue
FROM silver.monthly_support m
FULL OUTER JOIN acts_monthly a
    ON  m.case_id = a.case_id
    AND m.report_month = a.report_month
WHERE
       m.case_id IS NULL
    OR (
        a.case_id IS NULL
        AND COALESCE(m.current_collected, 0) <> 0
    )
    OR ABS(
        COALESCE(m.current_collected, 0)
        - COALESCE(a.derived_current_collected, 0)
    ) > 0.01
ORDER BY
    report_month,
    case_id;
GO
