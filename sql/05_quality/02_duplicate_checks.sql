USE ChildSupportReportingPortfolio;
GO

/* Duplicate payment IDs in ACTS: expected 0 rows */
SELECT payment_id,COUNT(*) AS row_count
FROM silver.acts_payments
GROUP BY payment_id
HAVING COUNT(*)>1;
GO

/* Duplicate payment IDs in CSDW: deliberate synthetic defects expected */
SELECT payment_id,COUNT(*) AS row_count,
       SUM(amount) AS duplicated_amount_total
FROM silver.csdw_payments
GROUP BY payment_id
HAVING COUNT(*)>1
ORDER BY row_count DESC,payment_id;
GO
