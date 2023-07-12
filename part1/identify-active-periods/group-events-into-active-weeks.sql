-- Presents an alternative method for calculating active periods for
-- non-subscription services by grouping events into active weeks.
-- (not used in this project)

-- We choose a measurement date of '2020-05-10' and an allowed gap between
-- active periods of 7 days.

WITH periods AS (
    SELECT i::timestamp AS period_start,
        i::timestamp + '7 day'::interval AS period_end
    FROM GENERATE_SERIES('2020-02-09', '2020-05-10', '7 day'::interval) i
)
INSERT INTO socialnet7.active_week (account_id, start_date, end_date)
SELECT account_id, period_start::date, period_end::date
FROM socialnet7.event
INNER JOIN periods
ON event_time >= period_start
AND event_time < period_end
GROUP BY account_id, period_start, period_end;