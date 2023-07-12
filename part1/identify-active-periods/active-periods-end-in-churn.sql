-- Find active periods ending in churn and their corresponding start dates.
-- This consists of four CTEs:

-- - active_period_params - contains the fixed constants that define when the
-- program will find churns and the maximum allowed gap between subscriptions
-- that is not considered a churn.
--  - end_dates - contains all subscriptions that have end dates within the desired
-- periods. As a convenience for the next step, it also calculates the maximum date
-- for which an extension could occur to extend this end date: the end date plus
-- the allowed gap defined in the parameters.
-- - extensions -  contains every subscription end date that has another subscription 
-- that extends it (an extension). This is any subscription for a matching
-- account that begins before the maximum extension date (calculated in the
-- end_dates CTE) and has an end date in the future or a null end date.
-- - churns- a recursive CTE that performs the key calculation of the algorithm:
--     - the initializing SELECT statement is an outer join between the end dates and
--     the extensions, which selects only end dates that don’t have an extension. These
--     are the churns. 
--     - the recursive SELECT statement finds earlier start dates for subscriptions that
--     come before the churn for the same account; the earliest of these is the
--     beginning of the active period.

-- We define a measurement date of '2020-05-10' and an allowed gap between subscriptions
-- of 7 days.

WITH RECURSIVE active_period_params AS (
    SELECT INTERVAL '7 day' AS allowed_gap,
        '2020-05-10'::date AS observe_end,
        '2020-02-09'::date AS observe_start
),
end_dates AS (
    SELECT distinct account_id, start_date, end_date,
    (end_date + allowed_gap)::date AS extension_max
    FROM socialnet7.subscription
    INNER JOIN active_period_params
    ON end_date BETWEEN observe_start AND observe_end
),
extensions AS (
    SELECT distinct e.account_id, e.end_date
    FROM end_dates e
    INNER JOIN socialnet7.subscription s
    ON e.account_id = s.account_id
    AND s.start_date <= e.extension_max
    AND (s.end_date > e.end_date OR s.end_date IS NULL)
),
churns AS (
    SELECT e.account_id, e.start_date, e.end_date AS churn_date
    FROM end_dates e 
    LEFT OUTER JOIN extensions x
    ON e.account_id = x.account_id
    AND e.end_date = x.end_date
    WHERE x.end_date IS NULL

    UNION

    SELECT s.account_id, s.start_date, e.churn_date
    FROM socialnet7.subscription s
    CROSS JOIN active_period_params
    INNER JOIN churns e 
    ON s.account_id = e.account_id
    AND s.start_date < e.start_date
    AND s.end_date >= (e.start_date - allowed_gap)::date
)
INSERT INTO socialnet7.active_period (account_id, start_date, churn_date)
SELECT account_id, MIN(start_date) AS start_date, churn_date
FROM churns
GROUP BY account_id, churn_date;