-- Calculate the currently ongoing active periods. This is a list of all accounts
-- that are currently in the middle of an active subscription and the earliest 
-- start date when they entered any active subscription that is continuous at present.

-- We choose a measurement date of '2020-05-10' and an acceptable gap between subscriptions
-- of 7 days.

-- 1) A CTE holds parameters controlling when and how active periods are found
-- 2) A recursive CTE fins all accounts that are currently active, then finds 
-- earlier subscriptions that overlap with or are continuous with but older than the
-- subscriptions currently found.
-- 3) An aggregate SELECT statement finds the earliest start date of any subscriptions
-- for each account.

WITH RECURSIVE active_period_params AS (
    SELECT interval '7' AS allowed_gap,
    '2020-05-10'::date AS calc_date
),
active AS (
    SELECT DISTINCT account_id, MIN(start_date) AS start_date
    FROM socialnet7.subscription
    INNER JOIN active_period_params
    ON start_date <= calc_date
    AND (end_date > calc_date OR end_date IS NULL)
    GROUP BY account_id

    UNION

    SELECT s.account_id, s.start_date
    FROM socialnet7.subscription s
    CROSS JOIN active_period_params
    INNER JOIN active e 
    ON s.account_id = e.account_id
    AND s.start_date < e.start_date
    AND s.end_date >= (e.start_date - allowed_gap)::date
)
INSERT INTO socialnet7.active_period (account_id, start_date, churn_date)
SELECT account_id, MIN(start_date) AS start_date, NULL::date AS churn_date
FROM active
GROUP BY account_id, churn_date;