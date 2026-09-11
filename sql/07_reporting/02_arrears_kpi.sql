USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 02_arrears_kpi.sql
--
-- Purpose:
-- Calculate the case-based arrears collection rate
-- by county and fiscal year.
--
-- Source:
--   mart.vw_case_arrears
--
-- Grain:
--   One row per county per fiscal year.
--
-- KPI:
--   Case-Based Arrears Collection Rate (%)
--
-- Formula:
--   Cases with Arrears Collection
--   ----------------------------- * 100
--   Cases with Arrears Balance
-- =====================================================

SELECT
    county_code,
    county,
    fiscal_year,

    -- Cases with an outstanding arrears balance
    SUM(
        CASE
            WHEN arrears_balance > 0
            THEN 1
            ELSE 0
        END
    ) AS cases_with_arrears,

    -- Arrears cases that received a collection
    SUM(
        CASE
            WHEN arrears_balance > 0
             AND arrears_collected > 0
            THEN 1
            ELSE 0
        END
    ) AS cases_with_arrears_collection,

    -- Case-Based Arrears Collection Rate (%)
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

GROUP BY
    county_code,
    county,
    fiscal_year

ORDER BY
    fiscal_year,
    county_code;
GO