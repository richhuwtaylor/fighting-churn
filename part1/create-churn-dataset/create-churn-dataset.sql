-- Create the churn analysis dataset by finding the metric value for each metric
-- type for each observation date for each account.

-- Use multiple SUM aggregate functions to flatten the 'tall' metric table into a
-- 'wide' analysis table. 

-- The account tenure must always have a value for a user who has active subscriptions 
-- or is in an active period of usage. The fact that account tenure always has a value
-- means the JOIN  always finds at least one metric around the observation
-- date for every account. The logic of the CASE statement means any other metrics being 
-- flattened are filled with zero, which effectively handles the problem of filling missing 
-- values.

WITH observation_params AS (
    SELECT INTERVAL %(metric_interval)s AS metric_period,
        %(from_yyyy-mm-dd)s::timestamp AS obs_start,
        %(to_yyyy-mm-dd)s::timestamp AS obs_end
)
SELECT m.account_id, o.observation_date, is_churn,
SUM(CASE WHEN metric_name_id=0 THEN metric_value ELSE 0 END) AS like_per_month,
SUM(CASE WHEN metric_name_id=1 THEN metric_value ELSE 0 END) AS newfriend_per_month,
SUM(CASE WHEN metric_name_id=2 THEN metric_value ELSE 0 END) AS post_per_month,
SUM(CASE WHEN metric_name_id=3 THEN metric_value ELSE 0 END) AS adview_per_month,
SUM(CASE WHEN metric_name_id=4 THEN metric_value ELSE 0 END) AS dislike_per_month,
SUM(CASE WHEN metric_name_id=5 THEN metric_value ELSE 0 END) AS unfriend_per_month,
SUM(CASE WHEN metric_name_id=6 THEN metric_value ELSE 0 END) AS message_per_month,
SUM(CASE WHEN metric_name_id=7 THEN metric_value ELSE 0 END) AS reply_per_month,
SUM(CASE WHEN metric_name_id=8 THEN metric_value ELSE 0 END) AS account_tenure
FROM socialnet7.metric m 
INNER JOIN observation_params
ON metric_time BETWEEN obs_start AND obs_end    
INNER JOIN socialnet7.observation o 
ON m.account_id = o.account_id
    AND m.metric_time > (o.observation_date - metric_period)::timestamp    
    AND m.metric_time <= o.observation_date::timestamp
GROUP BY m.account_id, metric_time, observation_date, is_churn    
ORDER BY observation_date, m.account_id;