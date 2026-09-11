USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 04_month_over_month_trend.sql
--
-- Purpose:
-- Analyze month-over-month changes in CURRENT support
-- collection performance by county.
--
-- Source:
--   mart.vw_monthly_case_support
--
-- Grain:
--   One row per county per report month.
--
-- Window Function:
--   LAG() retrieves the previous month's collection rate.
-- =====================================================


WITH monthly_county AS (

    -- Calculate county-level CURRENT support rate
    -- for each reporting month
    SELECT
        county_code,
        county,
        report_month,

        SUM(current_due) AS total_current_due,
        SUM(current_collected) AS total_current_collected,

        CAST(
            SUM(current_collected) * 100.0
            / NULLIF(SUM(current_due), 0)
            AS decimal(8,2)
        ) AS current_support_rate

    FROM mart.vw_monthly_case_support

    GROUP BY
        county_code,
        county,
        report_month
),

trend AS (

    -- Retrieve the previous month's rate for each county
    SELECT
        county_code,
        county,
        report_month,
        total_current_due,
        total_current_collected,
        current_support_rate,

        LAG(current_support_rate) OVER (
            PARTITION BY county_code
            ORDER BY report_month
        ) AS previous_month_rate

    FROM monthly_county
)

SELECT
    county_code,
    county,
    report_month,

    total_current_due,
    total_current_collected,

    current_support_rate,
    previous_month_rate,

    -- Percentage-point change from the previous month
    CAST(
        current_support_rate
        - previous_month_rate
        AS decimal(8,2)
    ) AS month_over_month_change

FROM trend

ORDER BY
    county_code,
    report_month;
GO