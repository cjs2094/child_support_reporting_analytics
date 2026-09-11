USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 03_reconciliation_summary.sql
--
-- Purpose:
-- Summarize ACTS-to-CSDW payment reconciliation results
-- and quantify the financial impact of exceptions.
--
-- Source:
--   dq.vw_acts_csdw_reconciliation
--
-- Key Metrics:
--   payment_count
--   financial_impact
--   average_impact_per_exception
-- =====================================================


-- =====================================================
-- 1. Reconciliation Status Summary
--
-- Summarize payment counts and absolute dollar
-- differences for each reconciliation status.
-- =====================================================

SELECT
    reconciliation_status,
    COUNT(*) AS payment_count,

    CAST(
        SUM(absolute_amount_difference)
        AS decimal(14,2)
    ) AS financial_impact

FROM dq.vw_acts_csdw_reconciliation

GROUP BY
    reconciliation_status

ORDER BY
    reconciliation_status;
GO


-- =====================================================
-- 2. Create Compact Reconciliation Summary View
--
-- Provides a reusable summary of reconciliation
-- results by status.
-- =====================================================

CREATE OR ALTER VIEW dq.vw_reconciliation_summary
AS

SELECT
    reconciliation_status,

    COUNT(*) AS payment_count,

    CAST(
        SUM(absolute_amount_difference)
        AS decimal(14,2)
    ) AS financial_impact

FROM dq.vw_acts_csdw_reconciliation

GROUP BY
    reconciliation_status;
GO


-- =====================================================
-- 3. Financial Impact by Reconciliation Exception
--
-- Quantify the financial impact of each exception type.
--
-- Absolute differences are used so that overstatements
-- and understatements do not offset each other.
--
-- MATCH records are excluded because they have no
-- reconciliation difference.
-- =====================================================

SELECT
    reconciliation_status,

    -- Number of exception payments
    COUNT(*) AS exception_count,

    -- Total dollar impact of the exception type
    CAST(
        SUM(absolute_amount_difference)
        AS decimal(14,2)
    ) AS financial_impact,

    -- Average dollar impact per exception
    CAST(
        AVG(absolute_amount_difference)
        AS decimal(14,2)
    ) AS avg_impact_per_exception

FROM dq.vw_acts_csdw_reconciliation

WHERE reconciliation_status <> 'MATCH'

GROUP BY
    reconciliation_status

ORDER BY
    financial_impact DESC;
GO


-- =====================================================
-- 4. Overall Reconciliation Exception Summary
--
-- Provide a high-level summary of all reconciliation
-- exceptions and their combined financial impact.
-- =====================================================

SELECT
    COUNT(*) AS total_exception_count,

    CAST(
        SUM(absolute_amount_difference)
        AS decimal(14,2)
    ) AS total_financial_impact,

    CAST(
        AVG(absolute_amount_difference)
        AS decimal(14,2)
    ) AS avg_financial_impact_per_exception

FROM dq.vw_acts_csdw_reconciliation

WHERE reconciliation_status <> 'MATCH';
GO