/* --------------------
   Case Study Questions:
   Pizza Metrics
   --------------------*/

SET search_path TO pizza_runner;
-- How many pizzas were ordered?
SELECT COUNT(pizza_id) as pizza_count
FROM customer_orders;
   
-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS order_count
FROM customer_orders;

-- How many successful orders were delivered by each runner?
 SELECT runner_id,
	COUNT(order_id) AS successful_orders
 FROM runner_orders
 WHERE cancellation is NULL
 GROUP BY runner_id;

--How many of each type of pizza was delivered?
SELECT  pizza_names.pizza_name,
	cte.pizza_type_count
FROM pizza_names
JOIN	
	(SELECT co.pizza_id,
		COUNT(co.order_id) AS pizza_type_count
	FROM runner_orders AS ru
	JOIN customer_orders AS co 
	ON co.order_id = ru.order_id 
	WHERE ru.cancellation is NULL
	GROUP BY co.pizza_id) AS cte
ON cte.pizza_id = pizza_names.pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 	customer_id, 
	SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meat_lovers,
	SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM customer_orders
GROUP BY customer_id;

-- What was the maximum number of pizzas delivered in a single order?
SELECT MAX(pizza_count_per_order) AS max_count
FROM (
  SELECT
	co.order_id,
	COUNT(co.pizza_id) AS pizza_count_per_order
  FROM runner_orders AS ru
  JOIN customer_orders AS co
  	ON co.order_id = ru.order_id
  WHERE ru.cancellation is NULL
  GROUP BY co.order_id) AS cte;

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
  co.customer_id,
  SUM(CASE WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1 ELSE 0 END) AS changes,
  SUM(CASE WHEN co.exclusions is NULL AND co.extras is NULL THEN 1 ELSE 0 END) AS no_change
FROM runner_orders AS ru
JOIN customer_orders AS co
  ON ru.order_id = co.order_id
WHERE ru.cancellation is NULL
GROUP BY co.customer_id
ORDER BY co.customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT
  SUM(CASE WHEN co.exclusions IS NOT NULL AND co.extras IS NOT NULL THEN 1 ELSE 0 END) AS pizza_count
FROM runner_orders AS ru
JOIN customer_orders AS co
  ON co.order_id = ru.order_id
WHERE ru.cancellation IS NULL;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT
  DATE_PART('hour', order_time) AS hour_of_day,
  COUNT(pizza_id) as pizza_count
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- What was the volume of orders for each day of the week?
SELECT
  TO_CHAR(order_time,'day') AS day_of_week,
  COUNT(pizza_id) AS pizza_count
FROM customer_orders
GROUP BY day_of_week, DATE_PART('dow', order_time)
ORDER BY DATE_PART('dow', order_time);

/* --------------------
   Case Study Questions:
   Runner and Customer Experience
   --------------------*/

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)


-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
  ru.runner_id,
  DATE_PART('minute', AVG(ru.pickup_time::timestamp - co.order_time)) AS avg_arrival_minutes
FROM runner_orders AS ru
JOIN customer_orders AS co 
 ON co.order_id = ru.order_id
WHERE ru.cancellation IS NULL
GROUP BY ru.runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
  ru.order_id,
  count(co.pizza_id) AS pizzas_count,
  ROUND(EXTRACT(EPOCH FROM (ru.pickup_time::TIMESTAMP - co.order_time))::DECIMAL/60, 2) AS avg_time,
  CASE  WHEN COUNT(co.pizza_id) = 1 THEN 'Takes more than 10 minutes to prepare'
	WHEN COUNT(co.pizza_id) > 1 THEN 'Preparation time is based on order quantity, approximately or more than 10 minutes per order' END AS relationship
FROM runner_orders AS ru
JOIN customer_orders AS co
  ON co.order_id = ru.order_id 
WHERE ru.pickup_time IS NOT NULL
GROUP BY ru.order_id, ru.pickup_time, co.order_time
ORDER BY ru.order_id;

-- What was the average distance travelled for each customer?
SELECT  runner_id,
	ROUND(AVG(distance::DECIMAL), 2) AS avg_distance
FROM runner_orders
GROUP BY runner_id
ORDER BY runner_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration::INT) - MIN(duration::INT) AS difference
FROM runner_orders;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
  ru.order_id,
  ru.runner_id,
  COUNT(co.pizza_id) AS pizza_count,
  ROUND(AVG(distance::DECIMAL), 1) AS distance,
  ROUND(AVG(duration::INT), 1) AS duration,
  ROUND(AVG(ru.distance::DECIMAL/ru.duration::INT)*60, 2) AS speed_kmh
FROM runner_orders AS ru
JOIN customer_orders AS co
  ON ru.order_id = co.order_id
WHERE ru.cancellation IS NULL
GROUP BY ru.order_id, ru.runner_id
ORDER BY speed_kmh DESC;

/*Finding:
Orders shown in decreasing order of average speed:
While the fastest order only carried 1 pizza and the slowest order carried 3 pizzas,
there is no clear trend that more pizzas slow down the delivery speed of an order.  
*/

-- What is the successful delivery percentage for each runner?
SELECT
  ru.runner_id,
  ROUND(100.0*cte.successful_order/COUNT(ru.order_id)) AS delivery_percent
FROM runner_orders AS ru
JOIN (
    SELECT
	runner_id,
	COUNT(order_id) AS successful_order
    FROM runner_orders
    WHERE pickup_time IS NOT NULL
    GROUP BY runner_id) AS cte
 ON cte.runner_id = ru.runner_id
GROUP BY ru.runner_id, cte.successful_order
ORDER BY ru.runner_id;

/* --------------------
   Case Study Questions:
   Ingredient Optimisation
   --------------------*/
 
-- What are the standard ingredients for each pizza?

WITH CTE AS (
	SELECT pz.pizza_id, STRING_AGG(pt.topping_name, ',') AS standard_ingredients
	FROM pizza_recipes AS pz
	JOIN pizza_toppings AS pt 
	  ON pz.toppings = pt.topping_id
	GROUP BY pz.pizza_id)
SELECT pizza_names.pizza_name, CTE.standard_ingredients
FROM pizza_names
JOIN CTE
  ON CTE.pizza_id = pizza_names.pizza_id;

-- What was the most commonly added extra?
WITH CTE_extras AS (SELECT 
  DISTINCT extras, 
  COUNT(order_id) AS total_order
FROM (
  SELECT 
      order_id, 
      pizza_id, 
      CAST(UNNEST(string_to_array(extras,',')) AS INT) AS extras
  FROM customer_orders
  WHERE extras IS NOT NULL) AS cte
GROUP BY extras
ORDER BY total_order DESC)
	
SELECT 
	pizza_toppings.topping_name, 
	CTE_extras.total_order
FROM pizza_toppings
JOIN CTE_extras
  ON CTE_extras.extras = pizza_toppings.topping_id
ORDER BY CTE_extras.total_order DESC
LIMIT 1;

-- What was the most common exclusion?
WITH CTE_exclusion AS (SELECT 
  DISTINCT exclusions, 
  COUNT(order_id) AS total_order
FROM (
  SELECT 
      order_id, 
      pizza_id, 
      CAST(UNNEST(string_to_array(exclusions,',')) AS INT) AS exclusions
  FROM customer_orders
  WHERE exclusions IS NOT NULL) AS cte
GROUP BY exclusions
ORDER BY total_order DESC)
	
SELECT 
	pizza_toppings.topping_name, 
	CTE_exclusion.total_order
FROM pizza_toppings
JOIN CTE_exclusion 
  ON CTE_exclusion.exclusions = pizza_toppings.topping_id
ORDER BY CTE_exclusion.total_order DESC
LIMIT 1;

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
SELECT *,
CASE WHEN pizza_id = 1 AND exclusions = '4' AND extras LIKE '%1%' AND extras LIKE '%5%' THEN 'Meat lover - Extra Bacon, Chicken - Exclude Cheese'
	WHEN pizza_id = 1 AND extras LIKE '%1%' AND extras LIKE '%4%' AND exclusions LIKE '%2%' AND exclusions LIKE '%6%' THEN 'Meat Lover - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese'
	WHEN exclusions LIKE '%4%' THEN 'Meat Lover - Exclude cheese'
	WHEN pizza_id = 1 AND extras LIKE'%1%' THEN 'Meat Lover - Extra Bacon'
    ELSE 'Meat Lover' END
FROM customer_orders
WHERE pizza_id = 1;
	
/* --------------------
   Case Study Questions:
   Pricing and Ratings
   --------------------*/

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT
SUM(CASE WHEN co.pizza_id = 1 THEN 12 ELSE 10 END) AS total_revenue
FROM customer_orders AS co
JOIN runner_orders AS ru
  ON ru.order_id = co.order_id
WHERE ru.cancellation IS NULL;

-- What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

WITH CTE_ex AS (
  SELECT 
    order_id, 
    customer_id, 
    pizza_id,
	CASE WHEN exclusions LIKE '%,%' THEN SPLIT_PART(exclusions, ',', 1) ELSE exclusions END AS exlusions_col1, 
	CASE WHEN exclusions LIKE '%,%' THEN SPLIT_PART(exclusions, ',', 2) END AS exlusions_col2,
	CASE WHEN extras LIKE '%,%' THEN SPLIT_PART(extras, ',', 1) ELSE extras END AS extras_col1,
	CASE WHEN extras LIKE '%,%' THEN SPLIT_PART(extras, ',', 2)  END AS extras_col2
  FROM customer_orders
  ORDER BY order_id)
 
SELECT
SUM(CASE WHEN CTE_ex.pizza_id = 1 AND CTE_ex.extras_col1 IS NOT NULL AND CTE_ex.extras_col2 IS NOT NULL THEN 14
    	WHEN CTE_ex.pizza_id = 1 AND CTE_ex.extras_col1 IS NULL AND CTE_ex.extras_col2 IS NULL THEN 12
    	WHEN CTE_ex.pizza_id = 1 AND CTE_ex.extras_col1 IS NOT NULL AND CTE_ex.extras_col2 IS NULL THEN 13
	WHEN CTE_ex.pizza_id = 2 AND CTE_ex.extras_col1 IS NULL AND CTE_ex.extras_col2 IS NULL THEN 10
    	WHEN CTE_ex.pizza_id = 2 AND CTE_ex.extras_col1 IS NOT NULL AND CTE_ex.extras_col2 IS NOT NULL THEN 12
    	ELSE 11 END) AS total_revenue2
FROM runner_orders AS ru  
JOIN CTE_ex 
  ON ru.order_id = CTE_ex.order_id
WHERE ru.pickup_time IS NOT NULL;
	
-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

WITH orders_per_runner AS (
  SELECT runner_id, COUNT(order_id) AS total_orders 
  FROM runner_orders
  GROUP BY runner_id),
  
  successful_rate AS (
  SELECT 
  	cte_num_of_success.runner_id, 
  	cte_num_of_success.success_orders, 
  	orders_per_runner.total_orders,
  	ROUND(100.0*cte_num_of_success.success_orders/orders_per_runner.total_orders::decimal, 2) AS rating_percent
  FROM orders_per_runner
  JOIN (
    SELECT runner_id, COUNT(order_id) AS success_orders
    FROM runner_orders
    WHERE cancellation IS NULL
    GROUP BY runner_id) AS cte_num_of_success
  ON cte_num_of_success.runner_id = orders_per_runner.runner_id
  GROUP BY cte_num_of_success.runner_id, cte_num_of_success.success_orders, orders_per_runner.total_orders),
  
  cte_time AS (
    SELECT 
        ru.runner_id, 
        co.order_id, 
        co.order_time, 
        ru.pickup_time::timestamp, 
        ROUND(EXTRACT(EPOCH FROM (ru.pickup_time::timestamp - co.order_time))::decimal/60, 2) AS time_between, 
        ru.duration
    FROM customer_orders AS co
    JOIN runner_orders AS ru
    ON ru.order_id = co.order_id
    WHERE ru.pickup_time IS NOT NULL),
    
  cte_speed AS (
      SELECT 
        runner_id, 
        ROUND(60*AVG(distance::DECIMAL)/ AVG(duration::INTEGER), 2) AS average_speed_kmh
      FROM runner_orders 
      WHERE pickup_time IS NOT NULL 
      GROUP BY runner_id),
  
  cte_time_speed AS (
    SELECT 
      cte_time.runner_id, 
      cte_time.order_id, 
      cte_time.order_time, 
      cte_time.pickup_time, 
      cte_time.time_between, 
      cte_time.duration, 
      cte_speed.average_speed_kmh
    FROM cte_time
    JOIN cte_speed
    ON cte_speed.runner_id = cte_time.runner_id),
  
  cte_total_pizza AS (
    SELECT customer_id, COUNT(pizza_id) AS total_pizza 
    FROM customer_orders
    GROUP BY customer_id),
  
  info_successful_diliveries AS (
    SELECT co.customer_id, co.order_id, cte_time_speed.runner_id,  cte_time_speed.order_time, cte_time_speed.pickup_time, cte_time_speed.time_between, cte_time_speed.duration, cte_time_speed.average_speed_kmh, successful_rate.rating_percent
    FROM customer_orders AS co
    LEFT JOIN cte_time_speed ON cte_time_speed.order_id = co.order_id
    LEFT JOIN successful_rate ON successful_rate.runner_id = cte_time_speed.runner_id)
    
SELECT info_successful_diliveries.*, cte_total_pizza.total_pizza
FROM info_successful_diliveries
JOIN cte_total_pizza
ON cte_total_pizza.customer_id = info_successful_diliveries.customer_id;

-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH cte_money AS (
  SELECT co.order_id, ru.runner_id, CASE WHEN co.pizza_id = 1 THEN COUNT(pizza_id)*12 ELSE COUNT(pizza_id)*10 END AS total_money
  FROM customer_orders AS co
  JOIN runner_orders AS ru
  ON co.order_id = ru.order_id
  WHERE ru.pickup_time <> 'null'
  GROUP BY co.order_id, ru.runner_id, co.pizza_id
  ORDER BY co.order_id),

cte_revenue AS ( 
  SELECT order_id, runner_id, SUM(total_money) AS total_revenue
  FROM cte_money
  GROUP BY order_id, runner_id),

cte_cost AS (
  SELECT order_id, runner_id, round(0.3*distance::DECIMAL, 2) AS total_cost
  FROM runner_orders
  WHERE pickup_time <> 'null'
  GROUP BY order_id, runner_id, distance
  ORDER BY order_id)

SELECT 
	cte_revenue.order_id, 
    cte_revenue.runner_id, 
    cte_revenue.total_revenue, 
    cte_cost.total_cost, 
    cte_revenue.total_revenue - cte_cost.total_cost AS total_profit
FROM cte_revenue
JOIN cte_cost 
ON cte_cost.order_id = cte_revenue.order_id;