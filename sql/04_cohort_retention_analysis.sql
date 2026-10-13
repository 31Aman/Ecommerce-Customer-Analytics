-- ==============================================================================
-- 04_cohort_retention_analysis.sql
-- Monthly Cohort Retention Matrix (Calculates Customer Retention Over Time)
-- ==============================================================================

WITH customer_first_purchase AS (
    -- Identify the inception month (cohort) for each customer
    SELECT
        CustomerID,
        DATE_TRUNC('month', MIN(InvoiceDate))::DATE AS cohort_month
    FROM v_cleaned_transactions
    WHERE NOT is_cancelled
    GROUP BY CustomerID
),

customer_activities AS (
    -- Map each customer's monthly activities against their cohort month
    SELECT
        t.CustomerID,
        fp.cohort_month,
        DATE_TRUNC('month', t.InvoiceDate)::DATE AS activity_month,
        -- Calculate index: 0 = signup month, 1 = month 1, etc.
        (EXTRACT(YEAR FROM t.InvoiceDate) - EXTRACT(YEAR FROM fp.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM t.InvoiceDate) - EXTRACT(MONTH FROM fp.cohort_month)) AS cohort_index
    FROM v_cleaned_transactions t
    JOIN customer_first_purchase fp ON t.CustomerID = fp.CustomerID
    WHERE NOT t.is_cancelled
    GROUP BY t.CustomerID, fp.cohort_month, t.InvoiceDate
),

cohort_size AS (
    -- Total count of distinct users in each cohort month
    SELECT
        cohort_month,
        COUNT(DISTINCT CustomerID) AS initial_cohort_users
    FROM customer_first_purchase
    GROUP BY cohort_month
),

cohort_retention_counts AS (
    -- Count of active users per cohort_month and cohort_index
    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT CustomerID) AS active_users
    FROM customer_activities
    GROUP BY cohort_month, cohort_index
)

-- Final Retention Table with Retention Percentages
SELECT
    r.cohort_month,
    s.initial_cohort_users,
    r.cohort_index,
    r.active_users,
    ROUND((r.active_users * 100.0 / s.initial_cohort_users), 2) AS retention_rate_pct
FROM cohort_retention_counts r
JOIN cohort_size s ON r.cohort_month = s.cohort_month
ORDER BY r.cohort_month, r.cohort_index;
