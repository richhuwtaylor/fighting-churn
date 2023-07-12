-- Checks the number of events of the specified type per day within the specified date range.

-- CTE with a sequence of generate dates is used in an outer join with event data
-- to ensure that every date has a result, even if there are no events on that date

-- if the events have numeric properties, sums the properties 

WITH date_range AS (
    SELECT i::timestamp AS calc_date
    FROM GENERATE_SERIES(%(from_yyyy-mm-dd)s, %(to_yyyy-mm-dd)s, '1 day'::interval) i
)
SELECT event_time::date AS event_date,
    COUNT(*) AS n_event
FROM date_range 
LEFT OUTER JOIN socialnet7.event e
ON calc_date = event_time::date
INNER JOIN socialnet7.event_type t
ON t.event_type_id = e.event_type_id
WHERE t.event_type_name = %(event2measure)s
GROUP BY event_date
ORDER BY event_date;