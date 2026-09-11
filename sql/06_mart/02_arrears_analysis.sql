USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- 02_arrears_analysis.sql
--
-- Purpose:
-- Create an analytics-ready dataset for analyzing
-- child support arrears performance.
--
-- Source:
--   silver.arrears_summary
--   silver.cases
--
-- Base View Grain:
--   One row per case per fiscal year.
--
-- Key Measures:
--   arrears_balance
--   arrears_collected
--
-- Key KPIs:
--   1. Case-Based Arrears Collection Rate
--   2. Dollar-Based Arrears Collection Rate
-- =====================================================


-- =====================================================
-- 1. Create Case-Level Arrears View
--
-- Combine arrears balances and collections with county
-- information for reporting and aggregation.
--
-- Grain:
-- One row per case per fiscal year.
-- =====================================================

CREATE OR ALTER VIEW mart.vw_case_arrears
AS

SELECT
    a.case_id,
    c.county_code,
    c.county,
    a.fiscal_year,
    a.arrears_balance,
    a.arrears_collected

FROM silver.arrears_summary a

JOIN silver.cases c
    ON a.case_id = c.case_id;
GO


-- =====================================================
-- 2. Case-Based Arrears Collection Rate
--
-- Primary arrears performance KPI.
--
-- Measures the percentage of cases with an arrears
-- balance that received an arrears collection.
--
-- Formula:
-- Cases with arrears collection
-- --------------------------------- * 100
-- Cases with an arrears balance
-- =====================================================

SELECT
    county_code,
    county,
    fiscal_year,

    -- Number of cases with an outstanding arrears balance
    SUM(
        CASE
            WHEN arrears_balance > 0 THEN 1
            ELSE 0
        END
    ) AS cases_with_arrears,

    -- Number of arrears cases with a collection
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
                    WHEN arrears_balance > 0 THEN 1
                    ELSE 0
                END
            ),
            0
        )
        AS decimal(8,2)
    ) AS arrears_case_collection_rate

FROM mart.vw_case_arrears

GROUP BY
    county_code,
    county,
    fiscal_year

ORDER BY
    fiscal_year,
    county_code;
GO


-- =====================================================
-- 3. Dollar-Based Arrears Collection Rate
--
-- Supplemental arrears performance KPI.
--
-- Measures the percentage of total arrears dollars
-- that were collected during the fiscal year.
--
-- Formula:
-- Total arrears collected
-- --------------------------- * 100
-- Total arrears balance
-- =====================================================

SELECT
    county_code,
    county,
    fiscal_year,

    -- Total outstanding arrears balance
    SUM(arrears_balance) AS total_arrears_balance,

    -- Total amount collected toward arrears
    SUM(arrears_collected) AS total_arrears_collected,

    -- Dollar-Based Arrears Collection Rate (%)
    CAST(
        SUM(arrears_collected) * 100.0
        /
        NULLIF(
            SUM(arrears_balance),
            0
        )
        AS decimal(8,2)
    ) AS arrears_dollar_collection_rate

FROM mart.vw_case_arrears

GROUP BY
    county_code,
    county,
    fiscal_year

ORDER BY
    fiscal_year,
    county_code;
GO


-- =====================================================
-- 4. Case-Level Detail Review
--
-- Review the underlying case-level arrears records
-- used to calculate the county-level KPIs.
-- =====================================================

SELECT
    case_id,
    county_code,
    county,
    fiscal_year,
    arrears_balance,
    arrears_collected

FROM mart.vw_case_arrears

ORDER BY
    case_id,
    fiscal_year,
    county_code;
GO