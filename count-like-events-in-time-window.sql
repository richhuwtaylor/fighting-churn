-- The simulated social network dataset contains events for users liking posts.

-- Count the number of such events for each account within the 28 days before a specified date.

WITH calc_date AS (
    SELECT '2020-05-06'::timestamp AS the_date
)
SELECT account_id, COUNT(*) AS n_like_permonth
FROM socialnet7.event e 
INNER JOIN calc_date d 
ON e.event_time <= d.the_date
AND e.event_time > d.the_date - interval '28 day'
INNER JOIN socialnet7.event_type t ON t.event_type_id = e.event_type_id
WHERE t.event_type_name = 'like'
GROUP BY account_id;
