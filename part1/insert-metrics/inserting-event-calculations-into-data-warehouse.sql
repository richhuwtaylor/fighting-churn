-- Save a metric for the number of 'like' events for each account into our 'metric' table.
-- Likes are aggregated over the 28-day period preceding each measurement date,
-- and measurements are made every 7 days.

-- We assume that the metric_name_id for the 'like' event is 0.

WITH date_vals AS (
    SELECT i::timestamp AS metric_date
    FROM GENERATE_SERIES('2020-02-02', '2020-05-10', '7 day'::interval) i
)
INSERT INTO socialnet7.metric (account_id, metric_time, metric_name_id, metric_value)
SELECT account_id, metric_date, 0, count(*) AS metric_value
FROM socialnet7.event e
INNER JOIN date_vals d
ON e.event_time < d.metric_date
AND e.event_time >= d.metric_date - interval '28 day'
INNER JOIN socialnet7.event_type t 
ON t.event_type_id = e.event_type_id 
WHERE t.event_type_name = 'like'
GROUP BY account_id, metric_date;


-- Insert the metric name 'like_permonth' into our data warehouse.

INSERT INTO socialnet7.metric_name (metric_name, metric_name_id) 
VALUES ('like_per_month', 0)
ON CONFLICT DO NOTHING;

-- Similar query pairs can be run to populate metrics for the other events types:
-- dislike, post, new friend, unfriend, adview, message, reply.