USE ChildSupportReportingPortfolio;
GO


-- =====================================================
-- Drop existing Bronze tables before rebuilding
-- =====================================================

DROP TABLE IF EXISTS bronze.cases_raw;
DROP TABLE IF EXISTS bronze.obligations_raw;
DROP TABLE IF EXISTS bronze.acts_payments_raw;
DROP TABLE IF EXISTS bronze.csdw_payments_raw;
DROP TABLE IF EXISTS bronze.monthly_support_raw;
DROP TABLE IF EXISTS bronze.arrears_summary_raw;
GO


-- =====================================================
-- 1. Create raw case master table
-- =====================================================

CREATE TABLE bronze.cases_raw (
    case_id         varchar(20),
    county_code     varchar(10),
    county          varchar(100),
    case_status     varchar(30),
    open_date       varchar(30)
);
GO


-- =====================================================
-- 2. Create raw support obligation table
-- =====================================================

CREATE TABLE bronze.obligations_raw (
    obligation_id       varchar(30),
    case_id             varchar(20),
    obligation_month    varchar(30),
    obligation_type     varchar(30),
    amount_due          varchar(50)
);
GO


-- =====================================================
-- 3. Create raw ACTS payment transaction table
-- =====================================================

CREATE TABLE bronze.acts_payments_raw (
    payment_id       varchar(30),
    case_id          varchar(20),
    county_code      varchar(10),
    county           varchar(100),
    payment_date     varchar(30),
    payment_type     varchar(30),
    amount           varchar(50),
    obligation_id    varchar(30)
);
GO


-- =====================================================
-- 4. Create raw CSDW payment table
-- =====================================================

CREATE TABLE bronze.csdw_payments_raw (
    payment_id       varchar(30),
    case_id          varchar(20),
    county_code      varchar(10),
    county           varchar(100),
    payment_date     varchar(30),
    payment_type     varchar(30),
    amount           varchar(50),
    obligation_id    varchar(30)
);
GO


-- =====================================================
-- 5. Create raw monthly support reporting table
-- =====================================================

CREATE TABLE bronze.monthly_support_raw (
    case_id              varchar(20),
    report_month         varchar(30),
    current_due          varchar(50),
    current_collected    varchar(50)
);
GO


-- =====================================================
-- 6. Create raw arrears summary table
-- =====================================================

CREATE TABLE bronze.arrears_summary_raw (
    case_id               varchar(20),
    fiscal_year           varchar(10),
    arrears_balance       varchar(50),
    arrears_collected     varchar(50)
);
GO