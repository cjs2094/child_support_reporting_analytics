USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 01_current_support_kpi.sql
--
-- Purpose:
-- Calculate monthly CURRENT support collection
-- performance by county.
--
-- Source:
--   mart.vw_monthly_case_support
--
-- Grain:
--   One row per county per report month.
--
-- KPI:
--   Current Support Collection Rate (%)
--
-- Formula:
--   Total Current Collected
--   ----------------------- * 100
--   Total Current Due
-- =====================================================

SELECT
    county_code,
    county,
    report_month,

    -- Total CURRENT support due
    SUM(current_due) AS total_current_due,

    -- Total CURRENT support collected
    SUM(current_collected) AS total_current_collected,

    -- Current Support Collection Rate (%)
    CAST(
        SUM(current_collected) * 100.0
        / NULLIF(SUM(current_due), 0)
        AS decimal(8,2)
    ) AS current_support_collection_rate

FROM mart.vw_monthly_case_support

GROUP BY
    county_code,
    county,
    report_month

ORDER BY
    report_month,
    county_code;
GO