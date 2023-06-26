-- measure the proportion of accounts with each metric

-- using the date range 2020-04-01 to 2020-05-06, we make a single measurement for this window
-- (rather than a day-by-day calculation)

-- 1) count the number of accounts that have active subscriptions in this time window
-- 2) count the number of accounts that had each type of metric in the time window
-- 3) calculate the percentage of accounts that had each type of metric by dividing 2 by 1
-- 4) measure other statistics of the metrics in the time window

with date_range AS (
    SELECT '2020-04-01'::timestamp AS start_date,
        '2020-05-06'::timestamp AS end_date
), 
account_count AS (
    SELECT COUNT(DISTINCT account_id) AS n_account
    FROM socialnet7.subscription s 
    INNER JOIN date_range d 
    ON s.start_date <= d.end_date
    AND (s.end_date >= d.start_date OR s.end_date IS NULL)
)
SELECT metric_name,
    COUNT(DISTINCT m.account_id) AS count_with_metric,
    n_account AS n_account,
    ROUND(((COUNT(DISTINCT m.account_id))::numeric/n_account) * 100, 1) AS pcnt_with_metric,
    ROUND(AVG(metric_value)::numeric, 2) AS avg_value,
    MIN(metric_value) AS min_value,
    MAX(metric_value) AS max_value,
    MIN(metric_time) AS earliest_metric,
    MAX(metric_time) AS last_metric
FROM socialnet7.metric m CROSS JOIN account_count
INNER JOIN date_range 
ON metric_time >= start_date
AND metric_time <= end_date
INNER JOIN socialnet7.metric_name n 
ON m.metric_name_id = n.metric_name_id
INNER JOIN socialnet7.subscription s
ON s.account_id = m.account_id
AND s.start_date <= m.metric_time
AND (s.end_date >= m.metric_time OR s.end_date IS NULL)
GROUP BY metric_name, n_account
ORDER BY metric_name;