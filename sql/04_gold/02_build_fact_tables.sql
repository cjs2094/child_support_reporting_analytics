USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- Build Gold fact tables
-- Create analytics-ready fact tables for obligation
-- and collection reporting.
-- =====================================================

DROP TABLE IF EXISTS gold.fact_obligation;
DROP TABLE IF EXISTS gold.fact_collection;
GO


-- =====================================================
-- 1. Obligation Fact
-- Grain: one CURRENT obligation per case per month
-- in this synthetic dataset.
--
-- Measures:
--   amount_due
--
-- Dimensions:
--   case
--   county
--   obligation date
-- =====================================================

SELECT
    o.obligation_id,
    dc.case_key,
    dco.county_key,
    dd.date_key AS obligation_date_key,
    o.obligation_month,
    o.obligation_type,
    o.amount_due
INTO gold.fact_obligation
FROM silver.obligations o

-- Resolve the case surrogate key
JOIN gold.dim_case dc
    ON o.case_id = dc.case_id

-- Retrieve the county associated with the case
JOIN silver.cases sc
    ON o.case_id = sc.case_id

-- Resolve the county surrogate key
JOIN gold.dim_county dco
    ON sc.county_code = dco.county_code

-- Resolve the date surrogate key
JOIN gold.dim_date dd
    ON o.obligation_month = dd.calendar_date;
GO


-- =====================================================
-- 2. Collection Fact
-- Grain: one ACTS payment transaction.
--
-- Measures:
--   amount
--
-- Dimensions:
--   case
--   county
--   payment date
--
-- obligation_id is retained to support payment-to-
-- obligation analysis and reconciliation.
-- =====================================================

SELECT
    p.payment_id,
    dc.case_key,
    dco.county_key,
    dd.date_key AS payment_date_key,
    p.payment_date,
    p.payment_type,
    p.amount,
    p.obligation_id
INTO gold.fact_collection
FROM silver.acts_payments p

-- Resolve the case surrogate key
JOIN gold.dim_case dc
    ON p.case_id = dc.case_id

-- Resolve the county surrogate key
JOIN gold.dim_county dco
    ON p.county_code = dco.county_code

-- Resolve the date surrogate key
JOIN gold.dim_date dd
    ON p.payment_date = dd.calendar_date;
GO