INSERT INTRO socialnet7.metric_name VALUES (%new_metric_id, concat('%new_metric_name'))
ON CONFLICT DO NOTHING;

WITH num_metric AS (
	SELECT account_id, metric_time, metric_value AS num_value
	FROM socialnet7.metric m 
	INNER JOIN metric_name n 
	ON n.metric_name_id = m.metric_name_id
	AND n.metric_name = '%num_metric'
	AND metric_time BETWEEN '2020-02-02' AND '2020-05-10'
), den_metric AS (
	SELECT account_id, metric_time, metric_value AS den_value
	FROM socialnet7.metric m 
	INNER JOIN metric_name n 
	ON n.metric_name_id = m.metric_name_id
	AND n.metric_name = '%den_metric'
	AND metric_time BETWEEN '2020-02-02' AND '2020-05-10'
)
INSERT INTO socialnet7.metric (account_id, metric_time, metric_name_id, metric_value)
SELECT d.account_id, d.metric_time, %new_metric_id,
	CASE WHEN den_value > 0
	    THEN coalesce(num_value,0.0)/den_value
	    ELSE 0
    END AS metric_value
FROM den_metric d  
LEFT OUTER JOIN num_metric n
	ON n.account_id = d.account_id
	AND n.metric_time = d.metric_time
ON CONFLICT DO NOTHING;