/* Query to view the first 100 records of the subscriptions table */
SELECT *
FROM subscriptions
LIMIT 100;

/* Query with 2 aggregate functions to find the minimum subscription_start (earliest subscription start date) and maximum subscription_end (most recent subscription end date) of the subscriptions table */
SELECT MIN(subscription_start) AS 'Earliest Subscription Start Date',
			 MAX(subscription_end) AS 'Most Recent Subscription End Date'
FROM subscriptions;

/* Query with a combination of the COUNT and DISTINCT aggregate functions to find the number of user segments in the subscriptions table */
SELECT COUNT(DISTINCT segment) AS 'No of User Segments'
FROM subscriptions;

/* Query that creates the months temporary table */
WITH months AS
(SELECT
	'2017-01-01' AS first_day,
 	'2017-01-31' AS last_day
 UNION
 SELECT
 	'2017-02-01' AS first_day,
 	'2017-02-28' AS last_day
 UNION
 SELECT
 	'2017-03-01' AS first_day,
 	'2017-03-31' AS last_day
),
/* Query that creates the cross_join temporary table by using CROSS JOIN on the subscriptions table and the months temporary table */
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months
),
/* Query that creates the status temporary table using CASE statements to determine whether the record id is active or canceled and of which user segment*/
status AS
(SELECT id,
 	first_day AS month,
 	CASE
 		WHEN 	(segment = 87)
 			AND (subscription_start < first_day)
 			AND (subscription_end > first_day
          OR subscription_end IS NULL
       	) THEN 1
 		ELSE 0
	END AS is_active_87,
 	CASE
 		WHEN  (segment = 30)
 			AND (subscription_start < first_day)
 		  AND (subscription_end > first_day
         OR subscription_end IS NULL
       ) THEN 1
 		ELSE 0
 END AS is_active_30,
 CASE
 	 WHEN (segment = 87)
 	 AND	subscription_end BETWEEN first_day AND last_day
 	 THEN 1
   ELSE 0
 END AS is_canceled_87,
 CASE
 	 WHEN (segment = 30)
 		AND	subscription_end BETWEEN first_day AND last_day
 	 THEN 1
   ELSE 0
 END AS is_canceled_30
 FROM cross_join),
 /* Query that creates the status_aggregate temporary table by using the SUM function to find out how many records are either active or canceled and of which user segment */
status_aggregate AS
(SELECT month,
 	SUM(is_active_87) AS 'sum_active_87',
 	SUM(is_active_30) AS 'sum_active_30',
 	SUM(is_canceled_87) AS 'sum_canceled_87',
 	SUM(is_canceled_30) AS 'sum_canceled_30'
 FROM status
 GROUP BY month
 )
 /* Query that calculates the churn rate each month. The calculations multiplied by 100 to produce the results as a percentage and are rounded to 2 decimal places for better readability */
SELECT month,
 	ROUND(100.0 * sum_canceled_87 / sum_active_87,2) AS '87_churn_rate',
  ROUND(100.0 * sum_canceled_30 / sum_active_30,2) AS '30_churn_rate'
 FROM status_aggregate;
