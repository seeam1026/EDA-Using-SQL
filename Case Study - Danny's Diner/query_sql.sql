/* --------------------
   Case Study Questions
   --------------------*/

SET search_path TO dannys_diner;
-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS total_amount
FROM sales
JOIN menu ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(order_date) AS visit_days
FROM sales
GROUP BY customer_id
ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT customer_id, order_date, product_name AS first_item
FROM (
  SELECT customer_id, menu.product_name, order_date, FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS first_order_date
  FROM sales
  JOIN menu
  ON menu.product_id = sales.product_id) AS first_day
WHERE order_date = first_order_date;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT menu.product_name, COUNT(*) AS item_count
FROM sales
JOIN menu
ON menu.product_id = sales.product_id
GROUP BY menu.product_name
ORDER BY item_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH CTE AS (
  SELECT 
  	customer_id, 
  	product_name, 
  	FIRST_VALUE(COUNT(*)) OVER(PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS most_popular_item, COUNT(*) AS item_count
  FROM sales
  JOIN menu ON menu.product_id = sales.product_id
  GROUP BY customer_id, product_name)

SELECT customer_id, product_name
FROM CTE
WHERE most_popular_item = item_count;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT CTE.customer_id, product_id AS first_item_mem
FROM (
  SELECT 
  	sales.customer_id, 
  	product_id, 
  	order_date, 
  	FIRST_VALUE(order_date) OVER(PARTITION BY sales.customer_id ORDER BY order_date) AS first_order_date_mem
  FROM sales
  JOIN members 
  ON members.customer_id = sales.customer_id
  AND order_date > join_date
) AS CTE
WHERE CTE.order_date = CTE.first_order_date_mem;

-- 7. Which item was purchased just before the customer became a member?

WITH sales_before_program AS (
  SELECT sales.customer_id, product_id, order_date, join_date
  FROM sales
  JOIN members 
  ON members.customer_id = sales.customer_id
  AND order_date < join_date
  GROUP BY sales.customer_id, product_id, order_date, join_date
  ORDER BY sales.customer_id, order_date),

latest_item AS (
SELECT *, FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS last_date
FROM sales_before_program)

SELECT customer_id, product_id
FROM latest_item
WHERE order_date = last_date;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
	sales.customer_id, 
    COUNT(*) AS total_item, 
    SUM(menu.price) AS total_amount
FROM sales
LEFT JOIN members
ON members.customer_id = sales.customer_id
JOIN menu
ON menu.product_id = sales.product_id
WHERE join_date > order_date OR (sales.customer_id = 'C' AND join_date IS NULL)
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	sales.customer_id, 
    SUM(CASE WHEN menu.product_name = 'sushi' THEN 20*price ELSE 10*price END) AS total_point 
FROM sales
JOIN menu
ON menu.product_id = sales.product_id
JOIN members
ON members.customer_id = sales.customer_id
AND join_date < order_date
GROUP BY sales.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
	sales.customer_id, 
	SUM(CASE WHEN order_date >= join_date AND order_date < join_date + INTERVAL '1 week' THEN price*20 
        WHEN (order_date >= join_date + INTERVAL '1 week' OR order_date < join_date) AND menu.product_name = 'sushi' THEN price*20 
        ELSE price*10 END) AS total_point
FROM sales
JOIN menu
ON menu.product_id = sales.product_id
JOIN members
ON members.customer_id = sales.customer_id
AND EXTRACT(MONTH FROM order_date) = '1'
GROUP BY sales.customer_id