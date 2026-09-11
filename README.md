# Child Support Reporting Analytics

End-to-end SQL Server analytics portfolio project for child support reporting, 
data reconciliation, data quality validation, and performance monitoring.

> **Note:** This project uses entirely synthetic data for educational and portfolio purposes.
> It does not contain real client data or reproduce official NC DHHS ACTS/CSDW schemas.

## Project Overview

This project simulates a child support reporting environment in which case,
obligation, payment, and arrears data are transformed into reporting-ready
datasets and performance measures.

The project demonstrates how SQL can be used to:

- Build a multi-layer reporting pipeline from raw source files
- Clean and validate case, obligation, and payment data
- Reconcile payment records between simulated ACTS and CSDW systems
- Detect missing records, amount mismatches, and duplicate transactions
- Calculate Current Support and Arrears collection performance
- Compare county performance and analyze month-over-month trends
- Validate reporting metrics against transaction-level source data

## Technology

- SQL Server
- SQL Server Management Studio (SSMS)
- SQL
- Tableau (in progress)

## Data Architecture

```text
Synthetic CSV Data
       │
       ▼
    Bronze
  Raw ingestion
       │
       ▼
    Silver
Cleaning & validation
       │
       ▼
     Gold
Dimensions & facts
       │
       ▼
     Mart
Analytics-ready views
       │
       ▼
   Reporting
KPIs & trend analysis
       │
       ▼
    Tableau (in progress)
