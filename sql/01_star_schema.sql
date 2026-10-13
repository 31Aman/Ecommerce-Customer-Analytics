-- ==============================================================================
-- 01_star_schema.sql
-- Star Schema Dimensional Model for E-Commerce Retail Analytics
-- ==============================================================================

-- Create Dimension: Customers
CREATE TABLE IF NOT EXISTS dim_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    first_purchase_date DATE,
    customer_status VARCHAR(20) DEFAULT 'Active'
);

-- Create Dimension: Products
CREATE TABLE IF NOT EXISTS dim_products (
    stock_code VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    standard_unit_price NUMERIC(10, 2) NOT NULL
);

-- Create Dimension: Date
CREATE TABLE IF NOT EXISTS dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    week_of_year INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

-- Create Fact: Transactions
CREATE TABLE IF NOT EXISTS fact_transactions (
    transaction_id SERIAL PRIMARY KEY,
    invoice_no VARCHAR(50) NOT NULL,
    stock_code VARCHAR(50) REFERENCES dim_products(stock_code),
    customer_id VARCHAR(50) REFERENCES dim_customers(customer_id),
    date_id INT REFERENCES dim_date(date_id),
    invoice_timestamp TIMESTAMP NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    is_cancelled BOOLEAN DEFAULT FALSE
);

-- Indexes for optimized querying and analytics aggregations
CREATE INDEX idx_fact_customer ON fact_transactions(customer_id);
CREATE INDEX idx_fact_invoice ON fact_transactions(invoice_no);
CREATE INDEX idx_fact_date ON fact_transactions(date_id);
CREATE INDEX idx_fact_product ON fact_transactions(stock_code);
