-- Calculate QA metrics for events

-- We check the count, mean average, min and max values for the 'like_per_month' metric 
-- for each date. 

-- Rather than aggregating by grouping by the metric_time column, we explicitly
-- set the dates that we want to check because this makes it obvious when a date
-- is missing metric calculations (these will have zero for the count).

-- - Create a CTE of the dates to check
-- - Create a CTE of the metric being tested
-- - Use an OUTER JOIN to calculate the result

WITH date_range AS (
    SELECT i::timestamp AS calc_date
    FROM GENERATE_SERIES(%(from_yyyy-mm-dd)s, %(to_yyyy-mm-dd)s, '7 day'::interval) i
),
the_metric AS (
    SELECT * FROM socialnet7.metric m
    INNER JOIN socialnet7.metric_name n ON m.metric_name_id = n.metric_name_id
    WHERE n.metric_name = %(metric2measure)s
)
SELECT calc_date, AVG(metric_value), COUNT(the_metric.*) AS n_calc, 
    MIN(metric_value), MAX(metric_value)
FROM date_range
LEFT OUTER JOIN the_metric
ON calc_date = metric_time
GROUP BY calc_date
ORDER BY calc_date;