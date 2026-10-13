-- ==============================================================================
-- 05_executive_kpis.sql
-- High-Level Executive KPIs & Performance Metrics
-- ==============================================================================

-- 1. Month-over-Month (MoM) Revenue Growth and Order Volume
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', InvoiceDate)::DATE AS sales_month,
        COUNT(DISTINCT InvoiceNo) AS total_orders,
        COUNT(DISTINCT CustomerID) AS active_customers,
        ROUND(SUM(TotalAmount), 2) AS monthly_revenue,
        ROUND(SUM(TotalAmount) / COUNT(DISTINCT InvoiceNo), 2) AS average_order_value
    FROM v_cleaned_transactions
    WHERE NOT is_cancelled
    GROUP BY DATE_TRUNC('month', InvoiceDate)::DATE
)
SELECT
    sales_month,
    total_orders,
    active_customers,
    monthly_revenue,
    average_order_value,
    LAG(monthly_revenue, 1) OVER (ORDER BY sales_month) AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY sales_month)) * 100.0 / 
        NULLIF(LAG(monthly_revenue, 1) OVER (ORDER BY sales_month), 0), 
        2
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY sales_month;

-- 2. Category Performance & Gross Margin Contribution
SELECT
    Category,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(TotalAmount), 2) AS category_revenue,
    ROUND(SUM(TotalAmount) * 100.0 / SUM(SUM(TotalAmount)) OVER(), 2) AS revenue_share_pct,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price
FROM v_cleaned_transactions
WHERE NOT is_cancelled
GROUP BY Category
ORDER BY category_revenue DESC;
