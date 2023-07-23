-- Extract a metrics dataset consisting of CURRENT customers, i.e. those that are active
-- at present time.

-- The CTE at the beginning selects all accounts with at least 14 days' tenure. 
-- This constraint ensures that customers have been observed for a few weeks before
-- their metrics are used. If we don't do this, most new customers will have low metrics
-- due to the short observation period.


WITH metric_date AS
(
    SELECT  max(metric_time) AS last_metric_time FROM socialnet7.metric
),
account_tenures AS (
    SELECT account_id, metric_value AS account_tenure
    FROM socialnet7.metric m 
    INNER JOIN metric_date 
    ON metric_time = last_metric_time
    WHERE metric_name_id = 8
    AND metric_value >= 14
)
SELECT s.account_id, d.last_metric_time AS observation_date,
sum(CASE WHEN metric_name_id=0 THEN metric_value ELSE 0 END) AS like_per_month,
sum(CASE WHEN metric_name_id=1 THEN metric_value ELSE 0 END) AS newfriend_per_month,
sum(CASE WHEN metric_name_id=2 THEN metric_value ELSE 0 END) AS post_per_month,
sum(CASE WHEN metric_name_id=3 THEN metric_value ELSE 0 END) AS adview_per_month,
sum(CASE WHEN metric_name_id=4 THEN metric_value ELSE 0 END) AS dislike_per_month,
sum(CASE WHEN metric_name_id=34 THEN metric_value ELSE 0 END) AS unfriend_per_month,
sum(CASE WHEN metric_name_id=6 THEN metric_value ELSE 0 END) AS message_per_month,
sum(CASE WHEN metric_name_id=7 THEN metric_value ELSE 0 END) AS reply_per_month,
sum(CASE WHEN metric_name_id=21 THEN metric_value ELSE 0 END) AS adview_per_post,
sum(CASE WHEN metric_name_id=22 THEN metric_value ELSE 0 END) AS reply_per_message,
sum(CASE WHEN metric_name_id=24 THEN metric_value ELSE 0 END) AS post_per_message,
sum(CASE WHEN metric_name_id=25 THEN metric_value ELSE 0 END) AS unfriend_per_newfriend,
sum(CASE WHEN metric_name_id=27 THEN metric_value ELSE 0 END) AS dislike_pcnt,
sum(CASE WHEN metric_name_id=30 THEN metric_value ELSE 0 END) AS newfriend_pcnt_chng,
sum(CASE WHEN metric_name_id=31 THEN metric_value ELSE 0 END) AS days_since_newfriend
FROM socialnet7.metric m 
INNER JOIN metric_date d 
ON m.metric_time = d.last_metric_time
INNER JOIN account_tenures a 
ON a.account_id = m.account_id
INNER JOIN socialnet7.subscription s 
ON m.account_id=s.account_id
WHERE s.start_date <= d.last_metric_time
AND (s.end_date >= d.last_metric_time OR s.end_date IS NULL)
GROUP BY s.account_id, d.last_metric_time
ORDER BY s.account_id;