-- ==============================================================================
-- 03_rfm_customer_segmentation.sql
-- Advanced RFM (Recency, Frequency, Monetary) Customer Segmentation
-- Uses CTEs, Window Functions (NTILE), and Classification Logic
-- ==============================================================================

WITH snapshot_date AS (
    -- Set reference anchor date to 1 day after the latest recorded transaction
    SELECT (MAX(InvoiceDate) + INTERVAL '1 day') AS reference_date
    FROM v_cleaned_transactions
),

customer_rfm_raw AS (
    SELECT
        t.CustomerID,
        t.Country,
        -- Recency: Days between reference date and most recent order
        EXTRACT(DAY FROM (s.reference_date - MAX(t.InvoiceDate))) AS recency_days,
        -- Frequency: Count of distinct completed orders (excluding cancellations)
        COUNT(DISTINCT CASE WHEN NOT t.is_cancelled THEN t.InvoiceNo END) AS frequency_orders,
        -- Monetary: Total gross spend on completed orders
        ROUND(SUM(CASE WHEN NOT t.is_cancelled THEN t.TotalAmount ELSE 0 END), 2) AS monetary_spend
    FROM v_cleaned_transactions t
    CROSS JOIN snapshot_date s
    GROUP BY t.CustomerID, t.Country, s.reference_date
    HAVING SUM(CASE WHEN NOT t.is_cancelled THEN t.TotalAmount ELSE 0 END) > 0
),

rfm_scoring AS (
    SELECT
        CustomerID,
        Country,
        recency_days,
        frequency_orders,
        monetary_spend,
        -- Quintile scoring: 5 = best, 1 = lowest
        -- For Recency: lower days is better, so inverted order
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_orders ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_spend ASC) AS m_score
    FROM customer_rfm_raw
),

rfm_segments AS (
    SELECT
        CustomerID,
        Country,
        recency_days,
        frequency_orders,
        monetary_spend,
        r_score,
        f_score,
        m_score,
        (r_score::VARCHAR || f_score::VARCHAR || m_score::VARCHAR) AS rfm_combined,
        -- Customer Segment categorization
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 3 AND f_score >= 1 AND m_score >= 2 THEN 'Potential Loyalists'
            WHEN r_score >= 4 AND f_score = 1 THEN 'Recent New Customers'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk (High Value)'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'Hibernating Big Spenders'
            WHEN r_score = 1 AND f_score <= 2 THEN 'Lost Customers'
            ELSE 'Promising / Needs Attention'
        END AS customer_segment
    FROM rfm_scoring
)

-- Summary view for Executive Reporting
SELECT
    customer_segment,
    COUNT(CustomerID) AS total_customers,
    ROUND(COUNT(CustomerID) * 100.0 / SUM(COUNT(CustomerID)) OVER(), 2) AS customer_share_pct,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency_orders), 1) AS avg_orders,
    ROUND(AVG(monetary_spend), 2) AS avg_revenue_per_user,
    ROUND(SUM(monetary_spend), 2) AS total_segment_revenue,
    ROUND(SUM(monetary_spend) * 100.0 / SUM(SUM(monetary_spend)) OVER(), 2) AS revenue_contribution_pct
FROM rfm_segments
GROUP BY customer_segment
ORDER BY total_segment_revenue DESC;
