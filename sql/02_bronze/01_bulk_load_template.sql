USE ChildSupportReportingPortfolio;
GO

-- CSV source folder
-- Update this path to match the actual location on your computer.
DECLARE @DataPath nvarchar(500)
    = N'C:\sql\child-support-reporting-analytics\data\raw\';

-- Variable used to store the dynamic BULK INSERT statement.
DECLARE @sql nvarchar(max);


-- =====================================================
-- 1. Load case master data into the Bronze layer
-- =====================================================

SET @sql =
    N'BULK INSERT bronze.cases_raw
      FROM ''' + @DataPath + N'cases.csv''
      WITH (
          FORMAT = ''CSV'',
          FIRSTROW = 2,
          FIELDQUOTE = ''"'',
          ROWTERMINATOR = ''0x0a''
      );';

EXEC(@sql);


-- =====================================================
-- 2. Load monthly support obligation data
-- =====================================================

SET @sql =
    N'BULK INSERT bronze.obligations_raw
      FROM ''' + @DataPath + N'obligations.csv''
      WITH (
          FORMAT = ''CSV'',
          FIRSTROW = 2,
          FIELDQUOTE = ''"'',
          ROWTERMINATOR = ''0x0a''
      );';

EXEC(@sql);


-- =====================================================
-- 3. Load ACTS source payment transactions
-- =====================================================

SET @sql =
    N'BULK INSERT bronze.acts_payments_raw
      FROM ''' + @DataPath + N'acts_payments.csv''
      WITH (
          FORMAT = ''CSV'',
          FIRSTROW = 2,
          FIELDQUOTE = ''"'',
          ROWTERMINATOR = ''0x0a''
      );';

EXEC(@sql);


-- =====================================================
-- 4. Load CSDW warehouse payment data
-- =====================================================

SET @sql =
    N'BULK INSERT bronze.csdw_payments_raw
      FROM ''' + @DataPath + N'csdw_payments.csv''
      WITH (
          FORMAT = ''CSV'',
          FIRSTROW = 2,
          FIELDQUOTE = ''"'',
          ROWTERMINATOR = ''0x0a''
      );';

EXEC(@sql);


-- =====================================================
-- 5. Load monthly support reporting data
-- =====================================================

SET @sql =
    N'BULK INSERT bronze.monthly_support_raw
      FROM ''' + @DataPath + N'monthly_support.csv''
      WITH (
          FORMAT = ''CSV'',
          FIRSTROW = 2,
          FIELDQUOTE = ''"'',
          ROWTERMINATOR = ''0x0a''
      );';

EXEC(@sql);


-- =====================================================
-- 6. Load annual arrears summary data
-- =====================================================

SET @sql =
    N'BULK INSERT bronze.arrears_summary_raw
      FROM ''' + @DataPath + N'arrears_summary.csv''
      WITH (
          FORMAT = ''CSV'',
          FIRSTROW = 2,
          FIELDQUOTE = ''"'',
          ROWTERMINATOR = ''0x0a''
      );';

EXEC(@sql);

GO