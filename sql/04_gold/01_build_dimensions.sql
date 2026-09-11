USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- Build Gold dimension tables
-- Create analytics-ready dimensions from cleaned
-- Silver-layer data for reporting and dashboard analysis.
-- =====================================================

DROP TABLE IF EXISTS gold.dim_case;
DROP TABLE IF EXISTS gold.dim_county;
DROP TABLE IF EXISTS gold.dim_date;
GO


-- =====================================================
-- 1. County Dimension
-- Create one record per county and assign a surrogate key.
-- County attributes are sourced from the cleaned case master.
-- =====================================================

SELECT
    ROW_NUMBER() OVER (ORDER BY county_code) AS county_key,
    county_code,
    county
INTO gold.dim_county
FROM (
    SELECT DISTINCT
        county_code,
        county
    FROM silver.cases
    WHERE county_code IS NOT NULL
) x;
GO


-- =====================================================
-- 2. Case Dimension
-- Create one record per child support case and assign
-- a surrogate key for use in Gold fact tables.
-- County attributes are maintained separately in dim_county.
-- =====================================================

SELECT
    ROW_NUMBER() OVER (ORDER BY c.case_id) AS case_key,
    c.case_id
INTO gold.dim_case
FROM silver.cases c;
GO


-- =====================================================
-- 3. Date Dimension
-- Collect distinct dates used in payment and obligation
-- data and create calendar attributes for time analysis.
-- =====================================================

WITH d AS (

    -- Payment transaction dates
    SELECT DISTINCT
        payment_date AS calendar_date
    FROM silver.acts_payments
    WHERE payment_date IS NOT NULL

    UNION

    -- Monthly obligation dates
    SELECT DISTINCT
        obligation_month
    FROM silver.obligations
    WHERE obligation_month IS NOT NULL
)

SELECT
    -- Surrogate-style date key in YYYYMMDD format
    CONVERT(int, CONVERT(char(8), calendar_date, 112)) AS date_key,

    calendar_date,

    -- Calendar attributes for reporting and aggregation
    YEAR(calendar_date) AS calendar_year,
    MONTH(calendar_date) AS calendar_month,
    DATENAME(month, calendar_date) AS month_name,

    -- First day of the month for monthly trend analysis
    DATEFROMPARTS(
        YEAR(calendar_date),
        MONTH(calendar_date),
        1
    ) AS month_start

INTO gold.dim_date
FROM d;
GO