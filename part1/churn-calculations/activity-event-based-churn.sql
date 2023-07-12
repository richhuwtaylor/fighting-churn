-- Calculate the standard churn rate, retention rate, number of start and end accounts and number of churn accounts
-- between March and April 2020 based on an inactivity interval of 1 month. Use CTEs to define intermediate tables in the query.

WITH date_range AS (
    SELECT '2020-03-01'::date AS start_date,
    '2020-04-01'::date AS end_date,
    interval '1 months' AS inactivity_interval
),
start_accounts AS (
    SELECT DISTINCT account_id
    FROM socialnet7.event e 
    INNER JOIN date_range d 
    ON e.event_time + inactivity_interval > start_date
    AND e.event_time <= start_date 
),
start_count AS (
    SELECT COUNT(*) AS n_start 
    FROM start_accounts
),
end_accounts AS (
    SELECT DISTINCT account_id
    FROM socialnet7.event e 
    INNER JOIN date_range d
    ON e.event_time + inactivity_interval > end_date
    AND e.event_time <= end_date
),
end_count AS (
    SELECT COUNT(*) AS n_end 
    FROM end_accounts
),
churned_accounts AS (
    SELECT DISTINCT s.account_id
    FROM start_accounts s
    LEFT OUTER JOIN end_accounts e 
    ON s.account_id = e.account_id
    WHERE e.account_id IS NULL
),
churn_count AS (
    SELECT COUNT(*) AS n_churn
    FROM churned_accounts 
)
SELECT round((n_churn / n_start::numeric), 3) AS churn_rate,
    round(1 - (n_churn / n_start::numeric), 3) AS retention_rate,
    n_start,
    n_churn
FROM start_count, end_count, churn_count;