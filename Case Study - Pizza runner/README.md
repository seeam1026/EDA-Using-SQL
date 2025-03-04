# 🍕 Case Study #2 - Pizza Runner
<p align="center">
<img src="/IMG/case study 2.png" width=40% height=40%>

## 📕 Table Of Contents
  - 🛠️ [Problem Statement](#problem-statement)
  - 📂 [Dataset](#-dataset)
  - ♻️ [Data Cleaning](#data-cleaning)
  - 🔍 [Data Exploration](#-data-exploration)

---

## 🛠Problem Statement

> Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”
> 
> Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so **Pizza Runner** was launched!
> 
> Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

---

## 📂 Dataset
<p align="center">
<img src="/Case Study - Pizza runner/Pizza Runner - erd.png">

Danny has shared with you 6 key datasets for this case study:

### **```runners```**
<details>
<summary>
View table
</summary>

The runners table shows the **```registration_date```** for each new runner.


|runner_id|registration_date|
|---------|-----------------|
|1        |1/1/2021         |
|2        |1/3/2021         |
|3        |1/8/2021         |
|4        |1/15/2021        |

</details>


### **```customer_orders```**

<details>
<summary>
View table
</summary>

Customer pizza orders are captured in the **```customer_orders```** table with 1 row for each individual pizza that is part of the order.

| order_id | customer_id | pizza_id | exclusions | extras | order_time          |
| -------- | ----------- | -------- | ---------- | ------ | ------------------- |
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02 |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52 |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23 |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23 |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46 |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46 |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46 |
| 5        | 104         | 1        | null       | 1      | 2020-01-08 21:00:29 |
| 6        | 101         | 2        | null       | null   | 2020-01-08 21:03:13 |
| 7        | 105         | 2        | null       | 1      | 2020-01-08 21:20:29 |
| 8        | 102         | 1        | null       | null   | 2020-01-09 23:54:33 |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59 |
| 10       | 104         | 1        | null       | null   | 2020-01-11 18:34:49 |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49 |

</details>

### **```runner_orders```**

<details>
<summary>
View table
</summary>

After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.

The **```pickup_time```** is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. 

The **```distance```** and **```duration```** fields are related to how far and long the runner had to travel to deliver the order to the respective customer.


| order_id | runner_id | pickup_time         | distance | duration   | cancellation            |
| -------- | --------- | ------------------- | -------- | ---------- | ----------------------- |
| 1        | 1         | 2020-01-01 18:15:34 | 20km     | 32 minutes |                         |
| 2        | 1         | 2020-01-01 19:10:54 | 20km     | 27 minutes |                         |
| 3        | 1         | 2020-01-03 00:12:37 | 13.4km   | 20 mins    |                         |
| 4        | 2         | 2020-01-04 13:53:03 | 23.4     | 40         |                         |
| 5        | 3         | 2020-01-08 21:10:57 | 10       | 15         |                         |
| 6        | 3         | null                | null     | null       | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25km     | 25mins     | null                    |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4 km  | 15 minute  | null                    |
| 9        | 2         | null                | null     | null       | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10km     | 10minutes  | null                    |


</details>

### **```pizza_names```**

<details>
<summary>
View table
</summary>

|pizza_id|pizza_name|
|--------|----------|
|1       |Meat Lovers|
|2       |Vegetarian|

</details>

### **```pizza_recipes```**

<details>
<summary>
View table
</summary>

Each **```pizza_id```** has a standard set of **```toppings```** which are used as part of the pizza recipe.


|pizza_id|toppings |
|--------|---------|
|1       |1, 2, 3, 4, 5, 6, 8, 10| 
|2       |4, 6, 7, 9, 11, 12| 

</details>

### **```pizza_toppings```**

<details>
<summary>
View table
</summary>

This table contains all of the **```topping_name```** values with their corresponding **```topping_id```** value.


|topping_id|topping_name|
|----------|------------|
|1         |Bacon       | 
|2         |BBQ Sauce   | 
|3         |Beef        |  
|4         |Cheese      |  
|5         |Chicken     |     
|6         |Mushrooms   |  
|7         |Onions      |     
|8         |Pepperoni   | 
|9         |Peppers     |   
|10        |Salami      | 
|11        |Tomatoes    | 
|12        |Tomato Sauce|

</details>

## ♻Data Cleaning
<details>
<summary>
Create table
</summary>

** **	
 ```sql
	DROP TABLE IF EXISTS runners;
	CREATE TABLE runners (
	  "runner_id" INTEGER,
	  "registration_date" DATE
	);
	INSERT INTO runners
	  ("runner_id", "registration_date")
	VALUES
	  (1, '2021-01-01'),
	  (2, '2021-01-03'),
	  (3, '2021-01-08'),
	  (4, '2021-01-15');
	
	
	DROP TABLE IF EXISTS customer_orders;
	CREATE TABLE customer_orders (
	  "order_id" INTEGER,
	  "customer_id" INTEGER,
	  "pizza_id" INTEGER,
	  "exclusions" VARCHAR(4),
	  "extras" VARCHAR(4),
	  "order_time" TIMESTAMP
	);
	
	INSERT INTO customer_orders
	  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
	VALUES
	  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
	  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
	  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
	  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
	  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
	  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
	  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
	  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
	  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
	  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
	  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
	  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
	  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
	  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
	
	
	DROP TABLE IF EXISTS runner_orders;
	CREATE TABLE runner_orders (
	  "order_id" INTEGER,
	  "runner_id" INTEGER,
	  "pickup_time" VARCHAR(19),
	  "distance" VARCHAR(7),
	  "duration" VARCHAR(10),
	  "cancellation" VARCHAR(23)
	);
	
	INSERT INTO runner_orders
	  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
	VALUES
	  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
	  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
	  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
	  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
	  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
	  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
	  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
	  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
	  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
	  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
	
	
	DROP TABLE IF EXISTS pizza_names;
	CREATE TABLE pizza_names (
	  "pizza_id" INTEGER,
	  "pizza_name" TEXT
	);
	INSERT INTO pizza_names
	  ("pizza_id", "pizza_name")
	VALUES
	  (1, 'Meatlovers'),
	  (2, 'Vegetarian');
	
	
	DROP TABLE IF EXISTS pizza_recipes;
	CREATE TABLE pizza_recipes (
	  "pizza_id" INTEGER,
	  "toppings" TEXT
	);
	INSERT INTO pizza_recipes
	  ("pizza_id", "toppings")
	VALUES
	  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
	  (2, '4, 6, 7, 9, 11, 12');
	
	
	DROP TABLE IF EXISTS pizza_toppings;
	CREATE TABLE pizza_toppings (
	  "topping_id" INTEGER,
	  "topping_name" TEXT
	);
	INSERT INTO pizza_toppings
	  ("topping_id", "topping_name")
	VALUES
	  (1, 'Bacon'),
	  (2, 'BBQ Sauce'),
	  (3, 'Beef'),
	  (4, 'Cheese'),
	  (5, 'Chicken'),
	  (6, 'Mushrooms'),
	  (7, 'Onions'),
	  (8, 'Pepperoni'),
	  (9, 'Peppers'),
	  (10, 'Salami'),
	  (11, 'Tomatoes'),
	  (12, 'Tomato Sauce');
```		
</details>

<details>
<summary>
Cleaning Data
</summary>

## Clean customer_orders data:
**```customer_orders```**
- Converting ```null``` and ```NaN``` values into blanks ```''``` in ```exclusions``` and ```extras```
```sql
	UPDATE customer_orders
	SET exclusions = CASE WHEN exclusions = '' or exclusions LIKE '%null%' or exclusions LIKE '%nan%' THEN NULL ELSE exclusions END,
	    extras = CASE WHEN extras = '' or extras LIKE '%null%' or extras LIKE '%nan%' THEN NULL ELSE extras END;
```
## Clean runner_orders data:
**```runner_orders```**

- Converting ```'null'``` text values into null values for ```pickup_time```, ```distance``` and ```duration```
- Extracting only numbers and decimal spaces for the distance and duration columns
- Converting blanks, ```'null'``` and ```NaN``` into null values for cancellation 
  ```sql
   UPDATE runner_orders
   SET 	pickup_time = CASE WHEN pickup_time LIKE '%null%' THEN NULL ELSE pickup_time END,
  	distance = CASE WHEN distance LIKE '%null%' THEN NULL ELSE distance END,
  	duration = CASE WHEN duration LIKE '%null%' THEN NULL ELSE duration END,
  	cancellation = CASE WHEN cancellation LIKE '%null%' or cancellation LIKE '%nan%' or cancellation = '' THEN NULL ELSE cancellation END;

    UPDATE runner_orders
    SET	distance = replace(distance, 'km', ''),
  	duration = trim(regexp_replace(duration, 'minute|mins|min|minutes', ''));

    SELECT * FROM runner_orders;
  ```

## Clean pizza_recipes data:
**```pizza_recipes```**

```sql
   CREATE TEMP TABLE temp_pizza_recipe(pizza_id INT, pizza_topping TEXT);
   INSERT INTO temp_pizza_recipe(pizza_id, pizza_topping)
   SELECT pizza_id, unnest(string_to_array(toppings, ',')) 
   FROM pizza_recipes;
   TRUNCATE TABLE pizza_recipes;
   INSERT INTO pizza_recipes(pizza_id, toppings)
   SELECT pizza_id, pizza_topping FROM temp_pizza_recipe;
   SELECT * FROM pizza_recipes;
	
   DROP TABLE IF EXISTS temp_pizza_recipe;
	
   ALTER TABLE pizza_recipes 
   ALTER COLUMN toppings TYPE INT
   USING toppings::INT;
```
	
</details>


## 🔍 Data Exploration

<details>
<summary> 
Pizza Metrics
</summary>

### **Q1. How many pizzas were ordered?**
```sql
SELECT COUNT(pizza_id) as pizza_count
FROM customer_orders
```
|pizza_count|
|-----------|
|14         |

### **Q2. How many unique customer orders were made?**
```sql
SELECT COUNT(DISTINCT order_id) AS order_count
FROM customer_orders;
```
|order_count|
|-----------|
|10         |


### **Q3. How many successful orders were delivered by each runner?**
```sql
 SELECT runner_id,
	COUNT(order_id) AS successful_orders
 FROM runner_orders
 WHERE cancellation is NULL
 GROUP BY runner_id;
```

| runner_id | successful_orders |
|-----------|-------------------|
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |


### **Q4. How many of each type of pizza was delivered?**
```SQL
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
ON cte.pizza_id = pizza_names.pizza_id
```

| pizza_name | pizza_type_count |
|------------|------------------|
| Meatlovers | 9                |
| Vegetarian | 3                |


### **Q5. How many Vegetarian and Meatlovers were ordered by each customer?**
```SQL
SELECT 	customer_id, 
	SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meat_lovers,
	SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM customer_orders
GROUP BY customer_id;
```

| customer_id | meat_lovers | vegetarian |
|-------------|-------------|------------|
| 101         | 2           | 1          |
| 103         | 3           | 1          |
| 104         | 3           | 0          |
| 105         | 0           | 1          |
| 102         | 2           | 1          |

### **Q6. What was the maximum number of pizzas delivered in a single order?**
```SQL
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
 ``` 

| max_count |
|-----------|
| 3         |


### **Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```SQL
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
```

| customer_id | changes | no_change |
|-------------|---------|-----------|
| 101         | 0       | 2         |
| 102         | 0       | 3         |
| 103         | 3       | 3         |
| 104         | 2       | 2         |
| 105         | 1       | 1         |


### **Q8. How many pizzas were delivered that had both exclusions and extras?**
```SQL
SELECT
  SUM(CASE WHEN co.exclusions IS NOT NULL AND co.extras IS NOT NULL THEN 1 ELSE 0 END) AS pizza_count
FROM runner_orders AS ru
JOIN customer_orders AS co
  ON co.order_id = ru.order_id
WHERE ru.cancellation IS NULL;
```  

| pizza_count |
|-------------|
| 1           |


### **Q9. What was the total volume of pizzas ordered for each hour of the day?**
```SQL
SELECT
  DATE_PART('hour', order_time) AS hour_of_day,
  COUNT(pizza_id) as pizza_count
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;
```

| hour_of_day | pizza_count |
|-------------|-------------|
| 11          | 1           |
| 12          | 2           |
| 13          | 3           |
| 18          | 3           |
| 19          | 1           |
| 21          | 3           |
| 23          | 1           |

### **Q10. What was the volume of orders for each day of the week?**
```SQL
SELECT
  TO_CHAR(order_time,'day') AS day_of_week,
  COUNT(pizza_id) AS pizza_count
FROM customer_orders
GROUP BY day_of_week, DATE_PART('dow', order_time)
ORDER BY DATE_PART('dow', order_time);
```

| day_of_week | pizza_count |
|-------------|-------------|
| Friday      | 1           |
| Saturday    | 5           |
| Thursday    | 3           |
| Wednesday   | 5           |

</details>

<details>
<summary>
Runner and Customer Experience
</summary>

### **Q1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```SQL
WITH runner_signups AS (
  SELECT
    runner_id,
    registration_date,
    registration_date - ((registration_date - '2021-01-01') % 7)  AS start_of_week
  FROM pizza_runner.runners
)
SELECT
  start_of_week,
  COUNT(runner_id) AS signups
FROM runner_signups
GROUP BY start_of_week
ORDER BY start_of_week;
```

| start_of_week            | signups |
|--------------------------|---------|
| 2021-01-01T00:00:00.000Z | 2       |
| 2021-01-08T00:00:00.000Z | 1       |
| 2021-01-15T00:00:00.000Z | 1       |

### **Q2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```SQL
SELECT
  ru.runner_id,
  DATE_PART('minute', AVG(ru.pickup_time::timestamp - co.order_time)) AS avg_arrival_minutes
FROM runner_orders AS ru
JOIN customer_orders AS co 
 ON co.order_id = ru.order_id
WHERE ru.cancellation IS NULL
GROUP BY ru.runner_id;
```
| runner_id | avg_arrival_minutes |
|-----------|---------------------|
| 1         | 15                  |
| 2         | 23                  |
| 3         | 10                  |

### **Q3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```SQL
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
```

| order_id | pizzas_count | avg_time | relationship                                                                                 |
| -------- | ------------ | -------- | -------------------------------------------------------------------------------------------- |
| 1        | 1            | 10.53    | Takes more than 10 minutes to prepare                                                        |
| 2        | 1            | 10.03    | Takes more than 10 minutes to prepare                                                        |
| 3        | 2            | 21.23    | Preparation time is based on order quantity, approximately or more than 10 minutes per order |
| 4        | 3            | 29.28    | Preparation time is based on order quantity, approximately or more than 10 minutes per order |
| 5        | 1            | 10.47    | Takes more than 10 minutes to prepare                                                        |
| 7        | 1            | 10.27    | Takes more than 10 minutes to prepare                                                        |
| 8        | 1            | 20.48    | Takes more than 10 minutes to prepare                                                        |
| 10       | 2            | 15.52    | Preparation time is based on order quantity, approximately or more than 10 minutes per order |


### **Q4. What was the average distance travelled for each runner?**
```SQL
SELECT  runner_id,
	ROUND(AVG(distance::DECIMAL), 2) AS avg_distance
FROM runner_orders
GROUP BY runner_id
ORDER BY runner_id;
```

| runner_id | avg_distance |
|-----------|--------------|
| 1         | 15.85        |
| 2         | 23.93        |
| 3         | 10.00        |

### **Q5. What was the difference between the longest and shortest delivery times for all orders?**
```SQL
SELECT MAX(duration::INT) - MIN(duration::INT) AS difference
FROM runner_orders;
```

| difference |
|------------|
| 30         |

### **Q6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```SQL
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
```

| order_id | runner_id | pizzas_count | distance | duration | speed_kmh |
|----------|-----------|--------------|----------|----------|-----------|
| 8        | 2         | 1            | 23.4     | 15       | 93.60 	|
| 7        | 2         | 1            | 25       | 25       | 60.00 	|
| 10       | 1         | 2            | 10       | 10       | 60.00 	|
| 2        | 1         | 1            | 20       | 27       | 44.44 	|
| 3        | 1         | 2            | 13.4     | 20       | 40.20 	|
| 5        | 3         | 1            | 10       | 15       | 40.00 	|
| 1        | 1         | 1            | 20       | 32       | 37.50 	|
| 4        | 2         | 3            | 23.4     | 40       | 35.10 	|

**Finding:**
- **Orders are listed in decreasing order of average speed:**
> *Although the fastest order delivered only 1 pizza and the slowest order delivered 3 pizzas, there is no clear trend indicating that more pizzas in an order result in slower delivery speeds.*


### **Q7. What is the successful delivery percentage for each runner?**
```sql
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
```

| runner_id | delivery_percent |
|-----------|------------------|
| 1         | 100              |
| 2         | 75               |
| 3         | 50               |


</details>

<details>
	<summary>
		Ingredient Optimisation
	</summary>
	
 ### **Q1. What are the standard ingredients for each pizza?**
 ```SQL
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
```
>Output

| pizza_name | standard_ingredients                                           |
| ---------- | -------------------------------------------------------------- |
| Meatlovers | Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami |
| Vegetarian | Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce          |

### **Q2. What was the most commonly added extra?**
```SQL
    WITH CTE_extras AS (
      SELECT DISTINCT extras, COUNT(order_id) AS total_order
      FROM (
      	SELECT order_id, pizza_id, CAST(UNNEST(string_to_array(extras,',')) AS INT) AS extras
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
```
>Output

| topping_name | total_order |
| ------------ | ----------- |
| Bacon        | 4           |

### **Q3. What was the most common exclusion?**
```SQL
    WITH CTE_exclusion AS (
      SELECT DISTINCT exclusions, COUNT(order_id) AS total_order
      FROM (
      	SELECT order_id, pizza_id, CAST(UNNEST(string_to_array(exclusions,',')) AS INT) AS exclusions
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
```
>Output

| topping_name | total_order |
| ------------ | ----------- |
| Cheese       | 4           |

### **Q4. Generate an order item for each record in the customers_orders table in the format of one of the following:**
* Meat Lovers
* Meat Lovers - Exclude Beef
* Meat Lovers - Extra Bacon
* Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
```SQL
    SELECT order_id, customer_id,
    CASE WHEN pizza_id = 1 AND exclusions = '4' AND extras LIKE '%1%' AND extras LIKE '%5%' THEN 'Meat lover - Extra Bacon, Chicken - Exclude Cheese'
    	WHEN pizza_id = 1 AND extras LIKE '%1%' AND extras LIKE '%4%' AND exclusions LIKE '%2%' AND exclusions LIKE '%6%' THEN 'Meat Lover - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese'
    	WHEN exclusions LIKE '%4%' THEN 'Meat Lover - Exclude cheese'
    	WHEN pizza_id = 1 AND extras LIKE'%1%' THEN 'Meat Lover - Extra Bacon'
        ELSE 'Meat Lover' END
    FROM customer_orders
    WHERE pizza_id = 1;

```
>Output

| order_id | customer_id | case                                                            |
| -------- | ----------- | --------------------------------------------------------------- |
| 1        | 101         | Meat Lover                                                      |
| 2        | 101         | Meat Lover                                                      |
| 3        | 102         | Meat Lover                                                      |
| 4        | 103         | Meat Lover - Exclude cheese                                     |
| 4        | 103         | Meat Lover - Exclude cheese                                     |
| 5        | 104         | Meat Lover - Extra Bacon                                        |
| 8        | 102         | Meat Lover                                                      |
| 9        | 103         | Meat lover - Extra Bacon, Chicken - Exclude Cheese              |
| 10       | 104         | Meat Lover                                                      |
| 10       | 104         | Meat Lover - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

</details>

<details>
	<summary>
		Pricing and Ratings
	</summary>
	
### **Q1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**
```SQL
    SELECT
    SUM(CASE WHEN co.pizza_id = 1 THEN 12 ELSE 10 END) AS total_revenue
    FROM customer_orders AS co
    JOIN runner_orders AS ru
    ON ru.order_id = co.order_id
    WHERE ru.cancellation IS NULL;
```
>Output

| total_revenue |
| ------------- |
| 138           |

### **Q2. What if there was an additional $1 charge for any pizza extras?**
* Add cheese is $1 extra
```SQL
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
        	ELSE 11 END) AS total_revenue
    FROM runner_orders AS ru  
    JOIN CTE_ex 
    ON ru.order_id = CTE_ex.order_id
    WHERE ru.pickup_time IS NOT NULL;

```
>Output

| total_revenue |
| ------------- |
| 142           |

### **Q3. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?**
* customer_id
* order_id
* runner_id
* rating
* order_time
* pickup_time
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas

```SQL
    WITH orders_per_runner AS (
      SELECT runner_id, COUNT(order_id) AS total_orders 
      FROM runner_orders
      GROUP BY runner_id),
      
      successful_rate AS (
      SELECT 
      	cte_num_of_success.runner_id, 
      	cte_num_of_success.success_orders, 
      	orders_per_runner.total_orders,
      	ROUND(100.0*cte_num_of_success.success_orders/orders_per_runner.total_orders::decimal, 2) AS rating
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
            ROUND(60*AVG(distance::DECIMAL)/ AVG(duration::INTEGER), 2) AS avg_speed
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
          cte_speed.avg_speed
        FROM cte_time
        JOIN cte_speed
        ON cte_speed.runner_id = cte_time.runner_id),
      
      cte_total_pizza AS (
        SELECT customer_id, COUNT(pizza_id) AS total_pizza 
        FROM customer_orders
        GROUP BY customer_id),
      
      info_successful_diliveries AS (
        SELECT co.customer_id, co.order_id, cte_time_speed.runner_id,  TO_CHAR(cte_time_speed.order_time, 'HH24:MI:SS') AS order_time, TO_CHAR(cte_time_speed.pickup_time, 'HH24:MI:SS') AS pickup_time, cte_time_speed.time_between, cte_time_speed.duration, cte_time_speed.avg_speed, successful_rate.rating
        FROM customer_orders AS co
        LEFT JOIN cte_time_speed ON cte_time_speed.order_id = co.order_id
        LEFT JOIN successful_rate ON successful_rate.runner_id = cte_time_speed.runner_id)
        
    SELECT info_successful_diliveries.*, cte_total_pizza.total_pizza
    FROM info_successful_diliveries
    JOIN cte_total_pizza
    ON cte_total_pizza.customer_id = info_successful_diliveries.customer_id;
```
>Output

| customer_id | order_id | runner_id | order_time | pickup_time | time_between | duration | avg_speed | rating | total_pizza |
| ----------- | -------- | --------- | ---------- | ----------- | ------------ | -------- | --------- | ------ | ----------- |
| 101         | 1        | 1         | 18:05:02   | 18:15:34    | 10.53        | 32       | 42.74     | 100.00 | 3           |
| 101         | 2        | 1         | 19:00:52   | 19:10:54    | 10.03        | 27       | 42.74     | 100.00 | 3           |
| 102         | 3        | 1         | 23:51:23   | 00:12:37    | 21.23        | 20       | 42.74     | 100.00 | 3           |
| 102         | 3        | 1         | 23:51:23   | 00:12:37    | 21.23        | 20       | 42.74     | 100.00 | 3           |
| 102         | 3        | 1         | 23:51:23   | 00:12:37    | 21.23        | 20       | 42.74     | 100.00 | 3           |
| 102         | 3        | 1         | 23:51:23   | 00:12:37    | 21.23        | 20       | 42.74     | 100.00 | 3           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 103         | 4        | 2         | 13:23:46   | 13:53:03    | 29.28        | 40       | 53.85     | 75.00  | 4           |
| 104         | 5        | 3         | 21:00:29   | 21:10:57    | 10.47        | 15       | 40.00     | 50.00  | 3           |
| 101         | 6        |           |            |             |              |          |           |        | 3           |
| 105         | 7        | 2         | 21:20:29   | 21:30:45    | 10.27        | 25       | 53.85     | 75.00  | 1           |
| 102         | 8        | 2         | 23:54:33   | 00:15:02    | 20.48        | 15       | 53.85     | 75.00  | 3           |
| 103         | 9        |           |            |             |              |          |           |        | 4           |
| 104         | 10       | 1         | 18:34:49   | 18:50:20    | 15.52        | 10       | 42.74     | 100.00 | 3           |
| 104         | 10       | 1         | 18:34:49   | 18:50:20    | 15.52        | 10       | 42.74     | 100.00 | 3           |
| 104         | 10       | 1         | 18:34:49   | 18:50:20    | 15.52        | 10       | 42.74     | 100.00 | 3           |
| 104         | 10       | 1         | 18:34:49   | 18:50:20    | 15.52        | 10       | 42.74     | 100.00 | 3           |


### **Q4. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**

```SQL
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
```
>Output

| order_id | runner_id | total_revenue | total_cost | total_profit |
| -------- | --------- | ------------- | ---------- | ------------ |
| 1        | 1         | 12            | 6.00       | 6.00         |
| 2        | 1         | 12            | 6.00       | 6.00         |
| 3        | 1         | 22            | 4.02       | 17.98        |
| 4        | 2         | 34            | 7.02       | 26.98        |
| 5        | 3         | 12            | 3.00       | 9.00         |
| 7        | 2         | 10            | 7.50       | 2.50         |
| 8        | 2         | 12            | 7.02       | 4.98         |
| 10       | 1         | 24            | 3.00       | 21.00        |

</details>