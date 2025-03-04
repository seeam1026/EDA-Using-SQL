# 🍽️ Case Study #1 - Danny's Diner
<p align="center">
<img src="/IMG/case study 1.png" width=40% height=40%>

## 📌 Table Of Contents
- [🛠️ Problem Statement](#problem-statement)
- [📊 Dataset](#dataset)
- [🔎 Data Exploration](#data-exploration)

---

## 🛠Problem Statement

>Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
>
>He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

---

## 📂 Dataset
<p align="center">
<img src="/Case Study - Danny&apos;s Diner/Danny&apos;s Diner - erd.png">

Danny has shared with you 3 key datasets for this case study:

### **```sales```**
<details>
<summary>
View table
</summary>

The sales table captures all **```customer_id```** level purchases with an corresponding **```order_date```** and **```product_id```** information for when and what menu items were ordered.

| customer_id | order_date | product_id |
| ----------- | ---------- | ---------- |
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

</details>


### **```menu```**

<details>
<summary>
View table
</summary>

The menu table maps the **```product_id```** to the actual **```product_name```** and **```price```** of each menu item.

| product_id | product_name | price |
| ---------- | ------------ | ----- |
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

</details>

### **```members```**

<details>
<summary>
View table
</summary>

The final members table captures the **```join_date```** when a **```customer_id```** joined the beta version of the Danny’s Diner loyalty program.


| customer_id | join_date  |
| ----------- | ---------- |
| A           | 2021-01-07 |
| B           | 2021-01-09 |

</details>

## 🔍 Data Exploration
	
### **Q1. What is the total amount each customer spent at the restaurant?**

```SQL
SELECT customer_id, SUM(price) AS total_amount
FROM sales
JOIN menu ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id;
```
>Output

| customer_id | total_amount |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

### **Q2. How many days has each customer visited the restaurant?**
```SQL
    SELECT customer_id, COUNT(order_date) AS visit_days
    FROM sales
    GROUP BY customer_id
    ORDER BY customer_id;
```
>Output

| customer_id | visit_days |
| ----------- | ---------- |
| A           | 6          |
| B           | 6          |
| C           | 3          |

### **Q3. What was the first item from the menu purchased by each customer?**
```SQL
    SELECT customer_id, order_date, product_name AS first_item
    FROM (
      SELECT customer_id, menu.product_name, order_date, FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS first_order_date
      FROM sales
      JOIN menu
      ON menu.product_id = sales.product_id) AS first_day
     WHERE order_date = first_order_date;
```

>Output

| customer_id | order_date | first_item |
| ----------- | ---------- | ---------- |
| A           | 2021-01-01 | curry      |
| A           | 2021-01-01 | sushi      |
| B           | 2021-01-01 | curry      |
| C           | 2021-01-01 | ramen      |
| C           | 2021-01-01 | ramen      |


### **Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```SQL
    SELECT menu.product_name, COUNT(*) AS item_count
    FROM sales
    JOIN menu
    ON menu.product_id = sales.product_id
    GROUP BY menu.product_name
    ORDER BY item_count DESC
    LIMIT 1;
```

>Ouput

| product_name | item_count |
| ------------ | ---------- |
| ramen        | 8          |

### **Q5. Which item was the most popular for each customer?**
```SQL
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

```
>Ouput

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | ramen        |
| B           | curry        |
| B           | sushi        |
| C           | ramen        |

### **Q6.Which item was purchased first by the customer after they became a member?**
```SQL
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
```
>Output

| customer_id | first_item_mem |
| ----------- | -------------- |
| A           | 3              |
| B           | 1              |

### **Q7. Which item was purchased just before the customer became a member?**
```SQL
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
```
>Output

| customer_id | product_id |
| ----------- | ---------- |
| A           | 1          |
| A           | 2          |
| B           | 1          |

### **Q8. What is the total items and amount spent for each member before they became a member?**
```SQL
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
```
>Output

| customer_id | total_item | total_amount |
| ----------- | ---------- | ------------ |
| A           | 2          | 25           |
| B           | 3          | 40           |
| C           | 3          | 36           |

### **Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```SQL
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
```
>Output

| customer_id | total_point |
| ----------- | ----------- |
| B           | 440         |
| A           | 360         |

### **Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```SQL
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
```
>Output

| customer_id | total_point |
| ----------- | ----------- |
| B           | 820         |
| A           | 1370        |


### **Bonus Questions. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.**

```SQL
    WITH CTE AS (
      SELECT 
      	sales.customer_id, 
      	order_date, 
      	product_name, price, 
      	CASE WHEN order_date < join_date THEN 'NY' ELSE 'Y' END AS members
      FROM sales
      JOIN menu
      ON sales.product_id = menu.product_id 
      LEFT JOIN members
      ON members.customer_id = sales.customer_id),
    
    cte_filter AS (
      SELECT *, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking 
      FROM CTE
      WHERE members = 'Y')
    
    SELECT CTE.*, cte_filter.ranking
    FROM CTE
    LEFT JOIN cte_filter
    ON cte.customer_id = cte_filter.customer_id
    AND cte.order_date = cte_filter.order_date
    ORDER BY cte.customer_id, cte.order_date
```
>Output

| customer_id | order_date | product_name | price | members | ranking |
| ----------- | ---------- | ------------ | ----- | ------- | ------- |
| A           | 2021-01-01 | sushi        | 10    | NY      |         |
| A           | 2021-01-01 | curry        | 15    | NY      |         |
| A           | 2021-01-07 | curry        | 15    | Y       | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y       | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y       | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y       | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y       | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y       | 3       |
| B           | 2021-01-01 | curry        | 15    | NY      |         |
| B           | 2021-01-02 | curry        | 15    | NY      |         |
| B           | 2021-01-04 | sushi        | 10    | NY      |         |
| B           | 2021-01-11 | sushi        | 10    | Y       | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y       | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y       | 3       |
| C           | 2021-01-01 | ramen        | 12    | Y       | 1       |
| C           | 2021-01-01 | ramen        | 12    | Y       | 1       |
| C           | 2021-01-01 | ramen        | 12    | Y       | 1       |
| C           | 2021-01-01 | ramen        | 12    | Y       | 1       |
| C           | 2021-01-07 | ramen        | 12    | Y       | 2       |