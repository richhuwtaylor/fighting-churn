-- Calculate the MRR churn rate between March AND April 2020, taking MRR loss due to downselling into account. 
-- Use CTEs to define intermediate tables in the query.

-- This would be applicable when customers pay a range of prices.

WITH date_range AS (    
	SELECT '2020-03-01'::date AS start_date, '2020-04-01'::date AS end_date
), 
start_accounts AS (
	SELECT account_id, sum (mrr) AS total_mrr    
	FROM socialnet7.subscription s 
    INNER JOIN date_range d 
    ON s.start_date <= d.start_date    
	AND (s.end_date > d.start_date or s.end_date IS NULL)
	GROUP BY account_id    
),
end_accounts AS    
(
	SELECT account_id, sum(mrr) AS total_mrr    
	FROM socialnet7.subscription s 
    INNER JOIN date_range d 
    ON s.start_date <= d.end_date    
	AND (s.end_date > d.end_date or s.end_date IS NULL)
	GROUP BY account_id    
), 
churned_accounts AS (
	SELECT s.account_id, sum(s.total_mrr) AS total_mrr    
	FROM start_accounts s 
	LEFT OUTER JOIN end_accounts e 
    ON s.account_id=e.account_id
	WHERE e.account_id IS NULL    
	GROUP BY s.account_id    	
),
downsell_accounts AS (
	SELECT s.account_id, s.total_mrr-e.total_mrr AS downsell_amount    
	FROM start_accounts s 
	INNER JOIN end_accounts e 
    ON s.account_id=e.account_id    
	WHERE e.total_mrr < s.total_mrr    
),
start_mrr AS (    
	SELECT sum (start_accounts.total_mrr) AS start_mrr 
    FROM start_accounts
), 
churn_mrr AS (    
	SELECT 	sum(churned_accounts.total_mrr) AS churn_mrr 
    FROM churned_accounts
), 
downsell_mrr AS (    
	SELECT coalesce(sum(downsell_accounts.downsell_amount),0.0) AS downsell_mrr
    FROM downsell_accounts
)
SELECT 
	(churn_mrr+downsell_mrr) /start_mrr AS mrr_churn_rate,    
	start_mrr,    
	churn_mrr, 
	downsell_mrr
FROM start_mrr, churn_mrr, downsell_mrr
