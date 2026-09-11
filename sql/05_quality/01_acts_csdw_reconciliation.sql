USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- ACTS vs CSDW Payment Reconciliation
--
-- Purpose:
-- Compare ACTS source payment transactions against CSDW
-- reporting records and identify missing, duplicated,
-- or amount-mismatched payments.
--
-- Grain:
-- One row per payment_id.
--
-- Reconciliation Status:
--   MATCH
--   AMOUNT_MISMATCH
--   DUPLICATE_IN_CSDW
--   MISSING_IN_ACTS
--   MISSING_IN_CSDW
--
-- Financial Impact:
-- Measures the dollar difference between the ACTS
-- source amount and the total amount recorded in CSDW.
-- =====================================================

CREATE OR ALTER VIEW dq.vw_acts_csdw_reconciliation
AS

WITH acts AS (

    -- ACTS is treated as the source-of-record
    -- for payment transactions.
    SELECT
        payment_id,
        case_id,
        payment_date,
        payment_type,
        amount AS acts_amount

    FROM silver.acts_payments
),

csdw AS (

    -- Aggregate CSDW records by payment_id so that
    -- duplicate records can be detected and their
    -- financial impact can be measured.
    SELECT
        payment_id,

        MAX(case_id) AS case_id,
        MAX(payment_date) AS payment_date,
        MAX(payment_type) AS payment_type,

        COUNT(*) AS csdw_row_count,

        SUM(amount) AS csdw_total_amount

    FROM silver.csdw_payments

    GROUP BY
        payment_id
)

SELECT

    COALESCE(a.payment_id, c.payment_id) AS payment_id,

    a.case_id AS acts_case_id,
    c.case_id AS csdw_case_id,

    a.payment_date AS acts_payment_date,
    c.payment_date AS csdw_payment_date,

    a.payment_type AS acts_payment_type,
    c.payment_type AS csdw_payment_type,

    a.acts_amount,

    c.csdw_total_amount,

    COALESCE(c.csdw_row_count, 0) AS csdw_row_count,


    -- Signed difference:
    -- Positive = CSDW reports more than ACTS
    -- Negative = CSDW reports less than ACTS
    CAST(
        COALESCE(c.csdw_total_amount, 0)
        - COALESCE(a.acts_amount, 0)
        AS decimal(12,2)
    ) AS amount_difference,


    -- Absolute financial impact:
    -- Used to quantify the magnitude of the exception
    -- regardless of overstatement or understatement.
    CAST(
        ABS(
            COALESCE(c.csdw_total_amount, 0)
            - COALESCE(a.acts_amount, 0)
        )
        AS decimal(12,2)
    ) AS absolute_amount_difference,


    -- Assign reconciliation status
    CASE
        WHEN a.payment_id IS NULL
            THEN 'MISSING_IN_ACTS'

        WHEN c.payment_id IS NULL
            THEN 'MISSING_IN_CSDW'

        WHEN c.csdw_row_count > 1
            THEN 'DUPLICATE_IN_CSDW'

        WHEN a.acts_amount <> c.csdw_total_amount
            THEN 'AMOUNT_MISMATCH'

        ELSE 'MATCH'
    END AS reconciliation_status


FROM acts a

FULL OUTER JOIN csdw c
    ON a.payment_id = c.payment_id;
GO