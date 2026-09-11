IF DB_ID('ChildSupportReportingPortfolio') IS NULL
    CREATE DATABASE ChildSupportReportingPortfolio;
GO

USE ChildSupportReportingPortfolio;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='bronze') EXEC('CREATE SCHEMA bronze');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='silver') EXEC('CREATE SCHEMA silver');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='gold') EXEC('CREATE SCHEMA gold');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='mart') EXEC('CREATE SCHEMA mart');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='dq') EXEC('CREATE SCHEMA dq');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='ref') EXEC('CREATE SCHEMA ref');
GO