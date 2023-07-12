-- Calculate the observation dates for each account. This script assumes that an 
-- active_period table exists with periods defined from subscriptions.

-- 1) Initialize the recursive CTE with one observation for every active_period:
--     a) Pick the first observation date to be one observation interval after the start
--     date, less the lead time. 
--     b) Set a counter to 1 on the observation. This is used to calculate the time of
--     later observations.
--     c) Set a Boolean indicating whether the churn date is between that observation
--     date and the next observation date, which will be the observation interval
--     after this observation date.
-- 2) Recursively insert additional observation dates into the CTE for each active period:
--     a) Increment the counter by one.
--     b) The new observation date is calculated from the start date plus the new
--     counter value multiplied by the observation period, less the lead time.
--     c) Set a Boolean indicator on every observation so that an observation that
--     immediately precedes the end of the active period (the churn) is set to true.
--     d) Exit recursion when one of the following conditions is met:
--     - The next observation date is after the end of the active period.
--     - The next observation date is after the end of the overall period being considered.

-- We choose an observation date of '2020-05-10' and a lead time of 1 week.

WITH RECURSIVE observation_params AS    
(    
	SELECT interval '1 month' AS obs_interval,
	       interval '1 week'  AS lead_time,
	       '2020-02-09'::date AS obs_start,
	       '2020-05-10'::date AS obs_end
),
observations AS (    
	SELECT  account_id, start_date, 1 AS obs_count,
	    (start_date + obs_interval - lead_time)::date AS obs_date,
	    CASE 
	        WHEN churn_date >= (start_date + obs_interval - lead_time)::date 
		        and churn_date <  (start_date + 2*obs_interval - lead_time)::date
			THEN true 
		    ELSE false 
		END AS is_churn    
	FROM socialnet7.active_period 
    INNER JOIN observation_params
	ON (churn_date > (obs_start + obs_interval - lead_time)::date OR churn_date IS NULL)

	UNION    

	SELECT  o.account_id, o.start_date, obs_count + 1 AS obs_count,
	    (o.start_date + (obs_count + 1)*obs_interval - lead_time)::date AS obs_date,
		CASE 
	        WHEN churn_date >= (o.start_date + (obs_count + 1)*obs_interval - lead_time)::date
		        AND churn_date < (o.start_date + (obs_count + 2)*obs_interval - lead_time)::date
            THEN true 
			ELSE false 
		END AS is_churn     
	FROM observations o
    INNER JOIN observation_params
	ON (o.start_date + (obs_count + 1)*obs_interval - lead_time)::date <= obs_end
	INNER JOIN active_period s ON s.account_id = o.account_id    
	AND (o.start_date + (obs_count + 1)*obs_interval - lead_time)::date >= s.start_date
	AND ((o.start_date + (obs_count + 1)*obs_interval - lead_time)::date < s.churn_date OR churn_date is null)
) 
INSERT INTO socialnet7.observation (account_id, observation_date, is_churn)
SELECT DISTINCT account_id, obs_date, is_churn
FROM observations
INNER JOIN observation_params 
ON obs_date BETWEEN obs_start AND obs_end;