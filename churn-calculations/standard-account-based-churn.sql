-- Calculate the standard (account-based) churn rate, retention rate, number of start accounts and number of churn accounts
-- between March and April 2020. Use CTEs to define intermediate tables in the query.

-- We assume that a single account can have multiple subscriptions.

-- The standard churn rate is used as the main operational metric when all subscribers
-- pay similar amounts or the subscription is free.

-- Include calculations of annual and monthly churn (so that these can be measured for any data range).

WITH date_range AS (
    SELECT '2020-03-01'::date AS start_date, '2020-04-01'::date as end_date
),
start_accounts AS (
    SELECT DISTINCT account_id
    FROM socialnet7.subscription s 
    INNER JOIN date_range d 
    ON s.start_date <= d.start_date
    AND (s.end_date > d.start_date OR s.end_date IS NULL) 
),
end_accounts AS (
    SELECT DISTINCT account_id 
    FROM socialnet7.subscription s 
    INNER JOIN date_range d ON
    (s.end_date > d.end_date OR s.end_date IS NULL)
),
churned_accounts AS (
    SELECT s.account_id
    FROM start_accounts s
    LEFT OUTER JOIN end_accounts e ON
    s.account_id=e.account_id
    WHERE e.account_id IS NULL
),
start_count AS (
    SELECT COUNT(*) AS n_start FROM start_accounts
),
churn_count AS (
    SELECT COUNT(*) AS n_churn FROM churned_accounts
)
SELECT ROUND((n_churn / n_start::numeric), 3) AS churn_rate,
    ROUND(1 - (n_churn / n_start::numeric), 3) AS retention_rate,
    n_start,
    n_churn,
    ROUND(1 - POWER(1 - n_churn / n_start::numeric, 365 / (end_date - start_date)::numeric), 3) AS annual_churn,
    ROUND(1 - POWER(1 - n_churn / n_start::numeric, (365/12::numeric) / (end_date - start_date)::numeric), 3) AS monthly_churn
FROM start_count, churn_count, date_range; 