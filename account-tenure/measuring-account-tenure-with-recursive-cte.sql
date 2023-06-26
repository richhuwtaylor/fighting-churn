-- Measures the tenure of each account with a recursive CTE approach.

-- Account tenure measure the length of time for which there is a continuous subscription for a single account through one or 
-- more subscriptions that can overlap or that can include short gaps.

-- Here, we consider 31 days to be the largest acceptable gap.

-- We set the calculation date to be the day after the simulation ends
-- (2020-07-01)

-- 1) The date_range CTE sets the date of the tenure calculation.
-- 2) The earlier_starts CTE selects the minimum date of any currently active subscription from the subscription table. 
-- To select active subscriptions, the query uses the usual check that a subscription is active if it starts before the
-- calculation date and ends on some future date (or has no defined end).
-- 3) The earlier_starts CTE then finds subscriptions starting earlier that also meet the end-date condition. 
-- To do so, it uses an inner join between the subscription table and the current CTE result set. 
-- The recursive part of the CTE joins on account IDs because the search for earlier start dates is performed 
-- separately for each account. 
-- 4) The final query after all the CTEs is an aggregation over the result in the recursive CTE, 
-- selecting the earliest start date as well as calculating the days since the earliest start in the current CTE.

WITH RECURSIVE date_range AS (   
	SELECT '2020-06-01'::date AS calc_date
),  
earlier_starts AS (
	SELECT account_id, MIN(start_date) AS start_date    
	FROM socialnet7.subscription 
    INNER JOIN date_range  
    ON start_date <= calc_date
    AND (end_date > calc_date OR end_date IS NULL)
	GROUP BY account_id

	UNION    
	
	SELECT s.account_id, s.start_date    
	FROM socialnet7.subscription s 
    INNER JOIN earlier_starts e 
		ON s.account_id=e.account_id    
		AND s.start_date < e.start_date    
		AND s.end_date >= (e.start_date-31)    	
) 
SELECT account_id, MIN(start_date) AS earliest_start,     
    calc_date-MIN(start_date) AS subscriber_tenure_days
FROM earlier_starts CROSS JOIN date_range    
GROUP BY account_id, calc_date    
ORDER BY account_id;