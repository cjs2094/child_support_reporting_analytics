USE ChildSupportReportingPortfolio;
GO

--CREATE SCHEMA mart;
--GO
-- =====================================================
-- 01_monthly_support_performance.sql
--
-- Purpose:
-- Create an analytics-ready dataset for monthly CURRENT
-- child support collection performance.
--
-- Grain:
-- One row per case per report month.
--
-- Key measures:
--   current_due
--   current_collected
--   current_support_rate
-- =====================================================


CREATE OR ALTER VIEW mart.vw_monthly_case_support
AS

WITH due AS (

    -- Aggregate CURRENT obligations by case and month
    SELECT
        dc.case_id,
        dco.county_code,
        dco.county,
        fo.obligation_month AS report_month,
        SUM(fo.amount_due) AS current_due

    FROM gold.fact_obligation fo

    JOIN gold.dim_case dc
        ON fo.case_key = dc.case_key

    JOIN gold.dim_county dco
        ON fo.county_key = dco.county_key

    WHERE fo.obligation_type = 'CURRENT'

    GROUP BY
        dc.case_id,
        dco.county_code,
        dco.county,
        fo.obligation_month
),

collected AS (

    -- Aggregate CURRENT ACTS collections by case and month
    SELECT
        dc.case_id,
        dco.county_code,

        DATEFROMPARTS(
            YEAR(fc.payment_date),
            MONTH(fc.payment_date),
            1
        ) AS report_month,

        SUM(fc.amount) AS current_collected

    FROM gold.fact_collection fc

    JOIN gold.dim_case dc
        ON fc.case_key = dc.case_key

    JOIN gold.dim_county dco
        ON fc.county_key = dco.county_key

    WHERE fc.payment_type = 'CURRENT'

    GROUP BY
        dc.case_id,
        dco.county_code,
        DATEFROMPARTS(
            YEAR(fc.payment_date),
            MONTH(fc.payment_date),
            1
        )
)

SELECT
    d.case_id,
    d.county_code,
    d.county,
    d.report_month,

    d.current_due,

    -- Cases without a CURRENT collection receive 0
    COALESCE(c.current_collected, 0) AS current_collected,

    -- Current Support Collection Rate (%)
    CAST(
        COALESCE(c.current_collected, 0) * 100.0
        / NULLIF(d.current_due, 0)
        AS decimal(8,2)
    ) AS current_support_rate

FROM due d

LEFT JOIN collected c
    ON  d.case_id = c.case_id
    AND d.county_code = c.county_code
    AND d.report_month = c.report_month;
GO


-- =====================================================
-- Validation / Preview
-- Review monthly case-level support performance.
-- =====================================================

SELECT *
FROM mart.vw_monthly_case_support
ORDER BY
    case_id,
    report_month,
    county_code;
GO