-- For 7-day intervals within the specified dates,
-- calculate the number of like events within the 28-day period before each date.

-- Uses the GENERATE_SERIES function to create a CTE containing a list of calculation dates.
-- Note that database types other than Postgres might not suppor this function.

WITH date_vals AS (
    SELECT i::timestamp AS metric_date
    FROM GENERATE_SERIES('2020-01-29', '2020-04-16', '7 day'::interval) i
)
SELECT account_id, metric_date, COUNT(*)
AS n_like_permonth
FROM socialnet7.event e
INNER JOIN date_vals d
ON e.event_time < d.metric_date
AND e.event_time >= d.metric_date - interval '28 day'
INNER JOIN socialnet7.event_type t
ON t.event_type_id = e.event_type_id
WHERE t.event_type_name = 'like'
GROUP BY account_id, metric_date
ORDER BY account_id, metric_date;