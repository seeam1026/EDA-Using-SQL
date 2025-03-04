/* --------------------
   Case Study Questions
   --------------------*/
SET search_path = foodie_fi;
-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customer
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT DATE_TRUNC('month', start_date)::DATE AS start_month, COUNT(*) AS trial_count
FROM subscriptions s
JOIN plans
ON plans.plan_id = s.plan_id
WHERE plans.plan_name = 'trial'
GROUP BY start_month
ORDER BY start_month;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT plan_name, COUNT(*) AS total_event
FROM subscriptions s
JOIN plans 
ON plans.plan_id = s.plan_id
WHERE EXTRACT(YEAR FROM start_date) > 2020
GROUP BY plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
   COUNT(DISTINCT customer_id) AS churned_customers, 
      ROUND(COUNT(DISTINCT customer_id)/
         (SELECT COUNT(DISTINCT customer_id) 
         FROM subscriptions)::DECIMAL*100.0, 2
      ) AS churn_percentage
FROM subscriptions s
JOIN plans
ON plans.plan_id = s.plan_id
WHERE plan_name = 'churn';

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH CTE AS (
   SELECT 
      customer_id, 
      plan_name, 
      LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS following_plan
      FROM subscriptions s
      JOIN plans 
      ON plans.plan_id = s.plan_id)
   
SELECT COUNT(DISTINCT customer_id) AS customer_count,
ROUND(100*COUNT(DISTINCT customer_id)/
   (SELECT COUNT(DISTINCT customer_id) 
   FROM subscriptions)::DECIMAL) AS early_churn_percentage
FROM CTE
WHERE plan_name = 'trial' AND following_plan = 'churn';

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH CTE AS (
   SELECT 
      customer_id, 
      start_date, 
      plan_name, 
      LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS next_plan 
   FROM subscriptions s
   JOIN plans 
   ON plans.plan_id = s.plan_id)
   
SELECT 
   next_plan, 
   ROUND(100.0*COUNT(DISTINCT customer_id) / 
      (SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions), 1) AS percentage
FROM CTE
WHERE plan_name = 'trial' AND next_plan IS NOT NULL
GROUP BY next_plan;
   
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH CTE AS (
   SELECT 
      customer_id, 
      plan_name, 
      start_date, 
      LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
      FROM subscriptions s
      JOIN plans 
      ON plans.plan_id = s.plan_id
      WHERE start_date <= '2020-12-31')
      
SELECT 
   plan_name, 
   COUNT(DISTINCT customer_id) AS customer_count, 
   ROUND(100.0*COUNT(DISTINCT customer_id)/ 
      (SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions)::DECIMAL, 1) AS percentage
FROM CTE
WHERE next_plan IS  NULL
GROUP BY plan_name;
   
-- 8. How many customers have upgraded to an annual plan in 2020?
WITH CTE AS (
   SELECT 
      customer_id, 
      start_date, 
      plan_name, 
      LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_start_date,
      LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
   FROM subscriptions s
   JOIN plans
   ON plans.plan_id = s.plan_id)
   
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM CTE
WHERE EXTRACT(YEAR FROM next_start_date) = 2020
AND plan_name != next_plan
AND next_plan = 'pro annual';
   
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH annual_subs AS (
   SELECT 
      customer_id, 
      start_date AS pro_annual_date, 
      plan_name, 
      FIRST_VALUE(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date) AS trial_plan,
      FIRST_VALUE(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS trial_start_date
   FROM subscriptions s
   JOIN plans
   ON plans.plan_id = s.plan_id )
   
SELECT ROUND(AVG(pro_annual_date - trial_start_date), 1) AS avg_days
FROM annual_subs
WHERE plan_name = 'pro annual' AND trial_plan = 'trial';

-- 10 Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH annual_subs AS (
   SELECT 
      customer_id, 
      start_date AS pro_annual_date, 
      plan_name, 
      FIRST_VALUE(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date) AS trial_plan,
      FIRST_VALUE(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS trial_start_date
      FROM subscriptions s
      JOIN plans
      ON plans.plan_id = s.plan_id )
   
SELECT 
CONCAT(FLOOR((pro_annual_date - trial_start_date)/30) * 30, ' - ', FLOOR((pro_annual_date - trial_start_date)/30) * 30 + 30, ' days') AS periods, 
COUNT(customer_id) AS total_customer,
ROUND(AVG(pro_annual_date - trial_start_date), 1) AS avg_days
FROM annual_subs
WHERE plan_name = 'pro annual' AND trial_plan = 'trial'
GROUP BY FLOOR((pro_annual_date - trial_start_date)/30);

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH cte_subs AS (
   SELECT 
      customer_id, 
      plan_name, 
      start_date, 
      LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan,
      LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_subs_date
   FROM subscriptions s
   JOIN plans
   ON plans.plan_id = s.plan_id)
   
SELECT COUNT(customer_id) AS downgrade_count
FROM cte_subs
WHERE EXTRACT (YEAR FROM next_subs_date) = 2020
AND plan_name = 'pro annual' AND next_plan = 'basic monthly'