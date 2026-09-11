USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 03_county_performance.sql
--
-- Purpose:
-- Compare county-level performance using the two
-- primary child support KPIs:
--
--   1. Current Support Collection Rate
--   2. Arrears Collection Rate
--
-- Current support is evaluated for a selected month.
-- Arrears performance is evaluated for a selected
-- fiscal year.
--
-- Grain:
--   One row per county.
-- =====================================================


DECLARE @report_month date = '2026-08-01';
DECLARE @fiscal_year int = 2026;


WITH current_support AS (

    -- Calculate Current Support Collection Rate
    -- for the selected reporting month
    SELECT
        county_code,
        county,

        SUM(current_due) AS total_current_due,
        SUM(current_collected) AS total_current_collected,

        CAST(
            SUM(current_collected) * 100.0
            / NULLIF(SUM(current_due), 0)
            AS decimal(8,2)
        ) AS current_support_rate

    FROM mart.vw_monthly_case_support

    WHERE report_month = @report_month

    GROUP BY
        county_code,
        county
),

arrears AS (

    -- Calculate Case-Based Arrears Collection Rate
    -- for the selected fiscal year
    SELECT
        county_code,
        county,

        SUM(
            CASE
                WHEN arrears_balance > 0
                THEN 1
                ELSE 0
            END
        ) AS cases_with_arrears,

        SUM(
            CASE
                WHEN arrears_balance > 0
                 AND arrears_collected > 0
                THEN 1
                ELSE 0
            END
        ) AS cases_with_arrears_collection,

        CAST(
            SUM(
                CASE
                    WHEN arrears_balance > 0
                     AND arrears_collected > 0
                    THEN 1
                    ELSE 0
                END
            ) * 100.0
            /
            NULLIF(
                SUM(
                    CASE
                        WHEN arrears_balance > 0
                        THEN 1
                        ELSE 0
                    END
                ),
                0
            )
            AS decimal(8,2)
        ) AS arrears_collection_rate

    FROM mart.vw_case_arrears

    WHERE fiscal_year = @fiscal_year

    GROUP BY
        county_code,
        county
)

SELECT
    COALESCE(cs.county_code, a.county_code) AS county_code,
    COALESCE(cs.county, a.county) AS county,

    cs.total_current_due,
    cs.total_current_collected,
    cs.current_support_rate,

    a.cases_with_arrears,
    a.cases_with_arrears_collection,
    a.arrears_collection_rate,

    -- Rank counties by CURRENT support performance
    RANK() OVER (
        ORDER BY cs.current_support_rate DESC
    ) AS current_support_rank

FROM current_support cs

FULL OUTER JOIN arrears a
    ON cs.county_code = a.county_code

ORDER BY
    current_support_rank,
    county_code;
GO