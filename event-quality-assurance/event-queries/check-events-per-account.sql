-- Counts the number of events per account per month. Here, we've
-- hard-coded the start and end dates to cover the length of the 
-- whole simulation (2020-01-01 to 2020-06-30).

-- 1) count the number of accounts which had active subscriptions 
-- in the time window
-- 2) count the total number of events in the time window
-- 3) divide the total number of events by the number of accounts,
-- then by the number of months that were measured

WITH
date_range AS (
    SELECT '2020-01-01'::timestamp AS start_date,
        '2020-06-30'::timestamp AS end_date
),
account_count AS (
    SELECT COUNT(DISTINCT account_id) AS n_account
    FROM socialnet7.subscription s
    INNER JOIN date_range d
    ON s.start_date <= d.end_date
    AND (s.end_date >= d.start_date OR s.end_date IS NULL)
)
SELECT event_type_name,
    COUNT(*) AS n_event,
    n_account AS n_account,
    ROUND(COUNT(*)::numeric / n_account, 1) AS events_per_account,
    ROUND(EXTRACT(days FROM end_date-start_date)::numeric / 28, 1) AS n_months,
    ROUND((COUNT(*)::numeric / n_account) / (EXTRACT(days FROM end_date-start_date)::numeric / 28), 1) 
    AS events_per_account_per_month
FROM socialnet7.event e
CROSS JOIN account_count
INNER JOIN socialnet7.event_type t
ON t.event_type_id = e.event_type_id
INNER JOIN date_range d
ON event_time >= start_date
AND event_time <= end_date
GROUP BY e.event_type_id, n_account, end_date, start_date, event_type_name
ORDER BY events_per_account_per_month DESC;

-- The results would suggest that people on this social network
-- do not unfriend their friends that much! It would be best to get
-- advice from somebody in the business as to whether observeed counts
-- of each event type per month are reasonable.