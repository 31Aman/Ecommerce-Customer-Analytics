-- ==============================================================================
-- 02_data_cleaning_etl.sql
-- Data Sanitization, Outlier Removal, and Staging to Production ETL
-- ==============================================================================

-- 1. Create Staging Table for Raw Transactions
CREATE TABLE IF NOT EXISTS staging_transactions (
    InvoiceNo VARCHAR(50),
    StockCode VARCHAR(50),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC(10, 2),
    CustomerID VARCHAR(50),
    Country VARCHAR(100),
    Category VARCHAR(100)
);

-- 2. Cleaned View eliminating bad records, missing IDs, and zero-price items
CREATE OR REPLACE VIEW v_cleaned_transactions AS
SELECT
    InvoiceNo,
    StockCode,
    TRIM(Description) AS Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    (Quantity * UnitPrice) AS TotalAmount,
    CustomerID,
    Country,
    Category,
    CASE 
        WHEN InvoiceNo LIKE 'C%' OR Quantity < 0 THEN TRUE 
        ELSE FALSE 
    END AS is_cancelled
FROM staging_transactions
WHERE CustomerID IS NOT NULL 
  AND CustomerID <> ''
  AND UnitPrice > 0;

-- 3. Data Quality Checks
-- Check percentage of cancelled orders
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN is_cancelled THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN is_cancelled THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM v_cleaned_transactions;
