-- Saves account tenure as a metric, as calculated over the date range
-- from 2020-02-02 to 2020-05-10 using 7-day intervals. 

-- We choose 31 days as the largest acceptable gap.

WITH RECURSIVE date_vals AS (
    SELECT i::timestamp AS metric_date
    FROM GENERATE_SERIES('2020-02-02', '2020-05-10', '7 day'::interval) i
),
earlier_starts AS
(
    SELECT account_id, metric_date,
    MIN(start_date) AS start_date
    FROM socialnet7.subscription 
    INNER JOIN date_vals
    ON start_date <= metric_date
    AND (end_date > metric_date OR end_date IS NULL)
    GROUP BY account_id, metric_date

    UNION

    SELECT s.account_id, metric_date, s.start_date
    FROM socialnet7.subscription s INNER JOIN earlier_starts e
    ON s.account_id =  e.account_id
    AND s.start_date < e.start_date
    AND s.end_date >= (e.start_date-31)
)
INSERT INTO socialnet7.metric (account_id, metric_time, metric_name_id, metric_value)
SELECT account_id, metric_date, 8 AS metric_name_id,
    EXTRACT(days FROM metric_date-MIN(start_date)) AS metric_value
FROM earlier_starts
GROUP BY account_id, metric_date
ORDER BY account_id, metric_date;