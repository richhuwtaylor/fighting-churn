-- Create a current customer dataset suitable for segmentation.

-- Here, we use max(metric_time) because we're interesed in the last date on which
-- we updated the data, although we could use any date instead.

WITH metric_date AS
(
    SELECT  max(metric_time) AS last_metric_time 
    FROM socialnet7.metric
)
SELECT m.account_id, d.last_metric_time,
sum(CASE WHEN metric_name_id=0 THEN metric_value ELSE 0 END) AS like_per_month,
sum(CASE WHEN metric_name_id=1 THEN metric_value ELSE 0 END) AS newfriend_per_month,
sum(CASE WHEN metric_name_id=2 THEN metric_value ELSE 0 END) AS post_per_month,
sum(CASE WHEN metric_name_id=3 THEN metric_value ELSE 0 END) AS adview_feed_per_month,
sum(CASE WHEN metric_name_id=4 THEN metric_value ELSE 0 END) AS dislike_per_month,
sum(CASE WHEN metric_name_id=5 THEN metric_value ELSE 0 END) AS unfriend_per_month,
sum(CASE WHEN metric_name_id=6 THEN metric_value ELSE 0 END) AS message_per_month,
sum(CASE WHEN metric_name_id=7 THEN metric_value ELSE 0 END) AS reply_per_month,
sum(CASE WHEN metric_name_id=8 THEN metric_value ELSE 0 END) AS account_tenure
FROM socialnet7.metric m 
INNER JOIN metric_date d 
ON m.metric_time = d.last_metric_time
INNER JOIN socialnet7.subscription s 
ON m.account_id=s.account_id
WHERE s.start_date <= d.last_metric_time
AND (s.end_date >= d.last_metric_time OR s.end_date IS NULL)
GROUP BY m.account_id, d.last_metric_time
ORDER BY m.account_id;