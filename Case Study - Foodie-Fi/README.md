# 🥑 Case Study #3 - Foodie-Fi
<p align="center">
<img src="/IMG/case study 3.png" width=40% height=40%>

## 📕 Table Of Contents
  - 🛠️ [Problem Statement](#problem-statement)
  - ♻️ [Entity Relationship Diagram](#entity-relationship-diagram)
  - 📂 [Dataset](#-dataset)
  - 🔍 [Data Exploration](#-data-exploration)

---

## 🛠Problem Statement

>Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!
>
>Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
>
>Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

---

## ♻Entity Relationship Diagram

<p align="center">
<img src="/Case Study - Foodie-Fi/case-study-3-erd.png">
  
## 📂 Dataset

Danny has shared the data design for Foodie-Fi and also short descriptions on each of the database tables - this case study focuses on only 2 tables but there will be a challenge to create a new table for the Foodie-Fi team.

### **```plans```**
<details>
<summary>
View table
</summary>

Customers can choose which plans to join Foodie-Fi when they first sign up.

Basic plan customers have limited access and can only stream their videos and is only available monthly at $9.90

Pro plan customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.

When customers cancel their Foodie-Fi service - they will have a churn plan record with a null **```price```** but their plan will continue until the end of the billing period.

| plan_id | plan_name     | price  |
| ------- | ------------- | ------ |
| 0       | trial         | 0.00   |
| 1       | basic monthly | 9.90   |
| 2       | pro monthly   | 19.90  |
| 3       | pro annual    | 199.00 |
| 4       | churn         |        |

</details>

### **```subscriptions```**

<details>
<summary>
View table
</summary>
  
Customer subscriptions show the exact date where their specific **```plan_id```** starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the **```start_date```** in the **```subscriptions```** table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.

When customers churn - they will keep their access until the end of their current billing period but the **```start_date```** will be technically the day they decided to cancel their service.

*Below is a sample of the top 10 rows of the **```foodie_fi.subscriptions```***

| customer_id | plan_id | start_date |
| ----------- | ------- | ---------- |
| 1           | 0       | 2020-08-01 |
| 1           | 1       | 2020-08-08 |
| 2           | 0       | 2020-09-20 |
| 2           | 3       | 2020-09-27 |
| 3           | 0       | 2020-01-13 |
| 3           | 1       | 2020-01-20 |
| 4           | 0       | 2020-01-17 |
| 4           | 1       | 2020-01-24 |
| 4           | 4       | 2020-04-21 |
| 5           | 0       | 2020-08-03 |

</details>

---

## 🔍 Data Exploration
<details>
<summary> 
Customer Journey
</summary>

### **Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey. Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!**

```SQL
    SELECT customer_id, s.plan_id, plan_name, start_date
    FROM foodie_fi.subscriptions s
    JOIN plans
    ON plans.plan_id = s.plan_id
    WHERE customer_id < 9
    ORDER BY customer_id, start_date;
```
>Output

| customer_id | plan_id | plan_name     | start_date |
| ----------- | ------- | ------------- | ---------- |
| 1           | 0       | trial         | 2020-08-01 |
| 1           | 1       | basic monthly | 2020-08-08 |
| 2           | 0       | trial         | 2020-09-20 |
| 2           | 3       | pro annual    | 2020-09-27 |
| 3           | 0       | trial         | 2020-01-13 |
| 3           | 1       | basic monthly | 2020-01-20 |
| 4           | 0       | trial         | 2020-01-17 |
| 4           | 1       | basic monthly | 2020-01-24 |
| 4           | 4       | churn         | 2020-04-21 |
| 5           | 0       | trial         | 2020-08-03 |
| 5           | 1       | basic monthly | 2020-08-10 |
| 6           | 0       | trial         | 2020-12-23 |
| 6           | 1       | basic monthly | 2020-12-30 |
| 6           | 4       | churn         | 2021-02-26 |
| 7           | 0       | trial         | 2020-02-05 |
| 7           | 1       | basic monthly | 2020-02-12 |
| 7           | 2       | pro monthly   | 2020-05-22 |
| 8           | 0       | trial         | 2020-06-11 |
| 8           | 1       | basic monthly | 2020-06-18 |
| 8           | 2       | pro monthly   | 2020-08-03 |

**Brief description about each customer’s onboarding journey:**

* Customer 1: Started with a trial on 2020-08-01, upgraded to a basic monthly plan on 2020-08-08.
* Customer 2: Began with a trial on 2020-09-20, transitioned to a pro annual plan on 2020-09-27.
* Customer 3: Initiated with a trial on 2020-01-13, moved to a basic monthly plan on 2020-01-20.
* Customer 4: Started with a trial on 2020-01-17, switched to a basic monthly plan on 2020-01-24, and churned on 2020-04-21.
* Customer 5: Began with a trial on 2020-08-03, upgraded to a basic monthly plan on 2020-08-10.
* Customer 6: Started with a trial on 2020-12-23, moved to a basic monthly plan on 2020-12-30, and churned on 2021-02-26.
* Customer 7: Started with a trial on 2020-02-05, transitioned to a basic monthly plan on 2020-02-12, and upgraded to a pro monthly plan on 2020-05-22.
* Customer 8: Began with a trial on 2020-06-11, upgraded to a basic monthly plan on 2020-06-18, and then switched to a pro monthly plan on 2020-08-03.
* The free trial period for all customers lasts exactly 7 days. 

</details>

<details>
<summary> 
Data Analysis Questions
</summary>

### **Q1. How many customers has Foodie-Fi ever had?**
```SQL
  SELECT COUNT(DISTINCT customer_id) AS total_customer
  FROM subscriptions
```
>Output

| total_customer |
| -------------- |
| 1000           |

### **Q2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value**
```SQL
  SELECT DATE_TRUNC('month', start_date)::DATE AS start_month, COUNT(*) AS trial_count
  FROM subscriptions s
  JOIN plans
  ON plans.plan_id = s.plan_id
  WHERE plans.plan_name = 'trial'
  GROUP BY start_month
  ORDER BY start_month;
```
>Output

| start_month | trial_count |
| ----------- | ----------- |
| 2020-01-01  | 88          |
| 2020-02-01  | 68          |
| 2020-03-01  | 94          |
| 2020-04-01  | 81          |
| 2020-05-01  | 88          |
| 2020-06-01  | 79          |
| 2020-07-01  | 89          |
| 2020-08-01  | 88          |
| 2020-09-01  | 87          |
| 2020-10-01  | 79          |
| 2020-11-01  | 75          |
| 2020-12-01  | 84          |

*There was not much variation in trial initiations between months. March had the highest number of trial (94), February had the lowest number of trial (68)*
### **Q3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**
```SQL
  SELECT plan_name, COUNT(*) AS total_event
  FROM subscriptions s
  JOIN plans 
  ON plans.plan_id = s.plan_id
  WHERE EXTRACT(YEAR FROM start_date) > 2020
  GROUP BY plan_name;
```
>Output

| plan_name     | total_event |
| ------------- | ----------- |
| pro annual    | 63          |
| churn         | 71          |
| pro monthly   | 60          |
| basic monthly | 8           |

*Pro plans (pro annual and pro monthly) performed well after 2020, but churn was high and popularity of basic monthly plan was low.*

### **Q4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**
```SQL
  SELECT 
    COUNT(DISTINCT customer_id) AS churned_customers, 
    ROUND(COUNT(DISTINCT customer_id)/(
      SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions)::DECIMAL*100.0, 2) AS churn_percentage
  FROM subscriptions s
  JOIN plans
  ON plans.plan_id = s.plan_id
  WHERE plan_name = 'churn';
```
>Output

| churned_customers | churn_percentage |
| ----------------- | ---------------- |
| 307               | 30.70            |

*Output shows churn percentage = 30.7% of total 1000 customers, this is a high rate, need to find the reason why customers leave (service quality, price, missing features...) and take measures to improve the situation.*

### **Q5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**
```SQL
  WITH CTE AS (
    SELECT 
      customer_id, 
      plan_name, 
      LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS following_plan
    FROM subscriptions s
    JOIN plans 
    ON plans.plan_id = s.plan_id)
      
  SELECT COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(100*COUNT(DISTINCT customer_id)/(
      SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions)::DECIMAL) AS early_churn_percentage
  FROM CTE
  WHERE plan_name = 'trial' AND following_plan = 'churn';
```
>Output

| customer_count | early_churn_percentage |
| -------------- | ---------------------- |
| 92             | 9                      |

*Output shows that the early churn rate is low (9%)*

### **Q6. What is the number and percentage of customer plans after their initial free trial?**
```SQL
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
    ROUND(100.0*COUNT(DISTINCT customer_id) / (
      SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions), 1) AS percentage
  FROM CTE
  WHERE plan_name = 'trial' AND next_plan IS NOT NULL
  GROUP BY next_plan;
```
>Output

| next_plan     | percentage |
| ------------- | ---------- |
| basic monthly | 54.6       |
| churn         | 9.2        |
| pro annual    | 3.7        |
| pro monthly   | 32.5       |

*Output shows that 54.6% of customers use the basic monthly plan after their initial free trial (highest rate), the pro monthly plan is quite popular (32.5%), and the pro annual plan is the lowest rate (3.7%). Needs to decrease 9,2% of customer churn, focus to increase 3.7% of customer use pro annual (discount, special feature...)*

### **Q7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**
```SQL
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
    ROUND(100.0*COUNT(DISTINCT customer_id)/ (
      SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions)::DECIMAL, 1) AS percentage
  FROM CTE
  WHERE next_plan IS  NULL
  GROUP BY plan_name;
```
>Output

| plan_name     | customer_count | percentage |
| ------------- | -------------- | ---------- |
| basic monthly | 224            | 22.4       |
| churn         | 236            | 23.6       |
| pro annual    | 195            | 19.5       |
| pro monthly   | 326            | 32.6       |
| trial         | 19             | 1.9        |

*Output shows that "pro monthly" is the most popular plan (32.6%), while churn remains significant at 23.6%. Most customers prefer flexibility over long-term commitment, as seen with the lower uptake of "pro annual" (19.5%). Addressing churn and promoting annual plans with added value or discounts could improve retention and revenue.*

### **Q8. How many customers have upgraded to an annual plan in 2020?**
```SQL
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
```
>Output

| customer_count |
| -------------- |
| 195            |

*Output shows: There are 195 customers upgraded to "pro annual" in 2020*
### **Q9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**
```SQL
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
```
>Output

| avg_days |
| -------- |
| 104.6    |

*It takes an average of 3.5 months for customers to pro annual plan from free trial*

### **Q10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)***
```SQL
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
```
>Output

| periods        | total_customer | avg_days |
| -------------- | -------------- | -------- |
| 0 - 30 days    | 48             | 9.5      |
| 30 - 60 days   | 25             | 41.8     |
| 60 - 90 days   | 33             | 70.9     |
| 90 - 120 days  | 35             | 99.8     |
| 120 - 150 days | 43             | 133.0    |
| 150 - 180 days | 35             | 161.5    |
| 180 - 210 days | 27             | 190.3    |
| 210 - 240 days | 4              | 224.3    |
| 240 - 270 days | 5              | 257.2    |
| 270 - 300 days | 1              | 285.0    |
| 300 - 330 days | 1              | 327.0    |
| 330 - 360 days | 1              | 346.0    |

*Shorter periods like 0-30 days and 30-60 days have significantly higher customer numbers than longer periods. Customers in these periods tend to upgrade their plans faster. 
After 210 days, A smaller percentage of customers make the decision to upgrade, then after 300 days, there are no more customers who upgrade.*
### **Q11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**
```SQL
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
```
>Output

| downgrade_count |
| --------------- |
| 0               |

*There is no customer has downgraded from pro monthly to basic monthly in 2020*

</details>