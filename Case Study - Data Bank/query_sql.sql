/* --------------------
   Case Study Questions:
   Customer Nodes Exploration
   --------------------*/
  SET search_path TO data_bank
-- How many unique nodes are there on the Data Bank system?
  SELECT COUNT(DISTINCT node_id) AS unique_nodes
  FROM data_bank.customer_nodes;

-- What is the number of nodes per region?
  SELECT regions.region_name, COUNT(customer_nodes.node_id) AS nodes
  FROM data_bank.customer_nodes
  JOIN data_bank.regions
  ON customer_nodes.region_id = regions.region_id
  GROUP BY regions.region_name
  ORDER BY nodes DESC;

-- How many customers are allocated to each region?
  SELECT regions.region_name, COUNT(DISTINCT customer_nodes.customer_id) AS num_of_customer
  FROM data_bank.customer_nodes
  JOIN data_bank.regions
  ON regions.region_id = customer_nodes.region_id
  GROUP BY regions.region_name
  ORDER BY num_of_customer DESC;

-- How many days on average are customers reallocated to a different node?
  WITH CTE AS (
    SELECT customer_id, node_id, start_date, end_date,
      LEAD(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_node_id, 
      LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_start_date
    FROM data_bank.customer_nodes)
  
  SELECT 
  ROUND(AVG(CASE WHEN node_id <> next_node_id THEN (next_start_date - start_date) END), 2) AS avg_reallocation_days
  FROM CTE
  WHERE next_node_id IS NOT NULL;

-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

  WITH CTE AS (
    SELECT 
    region_id,
    customer_id, 
    node_id, 
    start_date, 
    end_date, 
    LEAD(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_node_id, 
    LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_start_date
    FROM data_bank.customer_nodes),

  cte_reallocation_days AS (
    SELECT 
      regions.region_id, 
      regions.region_name, 
      CTE.next_start_date,
      CTE.start_date,
      CTE.next_start_date - CTE.start_date AS reallocation_days 
    FROM CTE
    JOIN data_bank.regions ON regions.region_id = CTE.region_id
    WHERE CTE.next_node_id IS NOT NULL AND CTE.node_id <> CTE.next_node_id)

  SELECT 
    region_name, 
    PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY reallocation_days) AS median_realocation_day,
    PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY reallocation_days) AS percent_80,
    PERCENTILE_CONT(0.95)  WITHIN GROUP (ORDER BY reallocation_days) AS percent_95
  FROM cte_reallocation_days
  GROUP BY region_name, region_id
  ORDER BY region_id;

/* --------------------
   Case Study Questions:
   Customer Transactions
   --------------------*/

-- What is the unique count and total amount for each transaction type?
  SELECT txn_type, COUNT(*) AS total_count, SUM(txn_amount) AS total_amount
  FROM data_bank.customer_transactions
  GROUP BY txn_type
  ORDER BY total_amount;

-- What is the average total historical deposit counts and amounts for all customers?
  SELECT 
    ROUND(AVG(deposit_count), 2) AS avg_deposit_count,
    ROUND(AVG(sum_amount), 2) AS avg_amount
  FROM (
    SELECT customer_id, COUNT(txn_type) AS deposit_count, SUM(txn_amount) AS sum_amount
    FROM data_bank.customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id) AS cte_customer_avg_amount;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
  WITH activity_count AS (
    SELECT 
      customer_id, 
      DATE_PART('month', txn_date) AS txn_month, 
      TO_CHAR(txn_date, 'month') AS month_name, 
      SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS total_deposit_monthly, 
      SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS total_withdrawal_monthly, 
      SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS total_purchase_monthly
    FROM data_bank.customer_transactions
    GROUP BY customer_id, txn_month, month_name)
  
  SELECT month_name, COUNT(customer_id) AS customer_count
  FROM activity_count
  WHERE total_deposit_monthly > 1 AND (total_withdrawal_monthly >= 1 OR total_purchase_monthly >= 1)
  GROUP BY txn_month, month_name
  ORDER BY txn_month;

-- What is the closing balance for each customer at the end of the month?
  WITH CTE_balance AS (
    SELECT 
      customer_id, 
      EXTRACT(MONTH FROM txn_date) AS txn_month,
      SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
        WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount 
        ELSE 0 END) AS balance_amount
    FROM data_bank.customer_transactions
    GROUP BY customer_id, txn_month)
  
  SELECT 
    customer_id,
    txn_month,
    SUM(balance_amount) OVER(PARTITION BY customer_id ORDER BY txn_month) AS ending_balance
  FROM CTE_balance;

-- What is the percentage of customers who increase their closing balance by more than 5%?
  WITH all_month AS (
    SELECT 
      customer_id, 
      generate_series(DATE_TRUNC('month', MIN(txn_date)), DATE_TRUNC('month', MAX(txn_date)), '1 month')::DATE AS txn_month
    FROM data_bank.customer_transactions
    GROUP BY customer_id),
  
  CTE_monthly_balance AS (
    SELECT 
      all_month.customer_id, 
      all_month.txn_month,
      COALESCE (SUM(CASE WHEN c.txn_type = 'deposit' THEN c.txn_amount 
                    WHEN c.txn_type IN('withdrawal', 'purchase') THEN -c.txn_amount
                    ELSE 0 END), 0) AS closing_balance
    FROM data_bank.customer_transactions c
    RIGHT JOIN all_month
    ON all_month.txn_month = DATE_TRUNC('month', c.txn_date) AND all_month.customer_id = c.customer_id
    GROUP BY all_month.customer_id, all_month.txn_month),
  
  closing_balance AS (
    SELECT 
      customer_id, 
      txn_month, 
      SUM(closing_balance) OVER(PARTITION BY customer_id ORDER BY txn_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ending_balance
    FROM CTE_monthly_balance),
  
  balance_with_lead AS (
    SELECT 
      customer_id, 
      txn_month, 
      ending_balance, 
      LEAD(ending_balance) OVER(PARTITION BY customer_id ORDER BY txn_month) AS next_month_balance
    FROM closing_balance),
  
  filter_customer AS (
    SELECT customer_id, (next_month_balance - ending_balance)/NULLIF(ending_balance, 0) AS pct_increase_5
    FROM balance_with_lead
    WHERE (next_month_balance - ending_balance)/NULLIF(ending_balance, 0) > 0.05
    GROUP BY customer_id, next_month_balance, ending_balance)
  
  SELECT ROUND(100.0*COUNT(DISTINCT customer_id)/
    (SELECT COUNT(DISTINCT customer_id) 
    FROM data_bank.customer_transactions), 2) AS pct_customers
  FROM filter_customer;

/* --------------------
   Case Study Questions:
   Data Allocation Challenge
   --------------------*/

-- To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

-- Option 1: data is allocated based off the amount of money at the end of the previous month
-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
-- Option 3: data is updated real-time
-- For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

-- running customer balance column that includes the impact each transaction
-- customer balance at the end of each month
-- minimum, average and maximum values of the running balance for each customer
-- Using all of the data available - how much data would have been required for each option on a monthly basis?

-- OPTION 1:
  WITH cte_running_balance AS (
    SELECT 
      customer_id, 
      EXTRACT(MONTH FROM txn_date) AS txn_month, 
      SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
          WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount 
          ELSE 0 END) AS running_balance_monthly
    FROM data_bank.customer_transactions
    GROUP BY customer_id, txn_month
    ORDER BY customer_id),
        
  end_balance_monthly AS (
    SELECT 
      customer_id, 
      txn_month, 
      running_balance_monthly, 
      SUM(running_balance_monthly) OVER(PARTITION BY customer_id ORDER BY txn_month) AS end_running_balance
    FROM cte_running_balance)
  
  SELECT txn_month, SUM(end_running_balance) AS total_end_running_balance_month
  FROM end_balance_monthly
  GROUP BY txn_month
  ORDER BY txn_month;

-- OPTION 2:
  WITH running_balance AS (
    SELECT customer_id, txn_date, txn_amount, EXTRACT(MONTH FROM txn_date) AS txn_month,
      CASE WHEN txn_type = 'deposit' THEN txn_amount
          WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount ELSE 0 END AS running_balance
    FROM data_bank.customer_transactions
    ORDER BY customer_id, txn_date),
  
  daily_balance AS (
    SELECT customer_id, txn_date, txn_month, txn_amount, running_balance, SUM(running_balance) OVER(PARTITION BY customer_id ORDER BY txn_date) AS end_running_balance
  FROM running_balance),
  
  avg_rolling_balance AS (
    SELECT 
      customer_id, 
      txn_date, 
      txn_month, 
      txn_amount, 
      running_balance, 
      end_running_balance, 
      ROUND(AVG(end_running_balance) OVER(PARTITION BY customer_id ORDER BY txn_date RANGE BETWEEN INTERVAL '30 DAYS' PRECEDING AND CURRENT ROW)) AS avg_rolling_30days_running_balance
    FROM daily_balance)
    
  SELECT txn_month, SUM(avg_rolling_30days_running_balance) AS total_avg_rolling_balance
  FROM avg_rolling_balance
  GROUP BY txn_month
  ORDER BY txn_month;

-- OPTION 3:
  WITH running_balances AS (
    SELECT customer_id, txn_date, txn_type, txn_amount, 
      EXTRACT(MONTH FROM txn_date) AS txn_month, 
      CASE WHEN txn_type = 'deposit' THEN txn_amount
        WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount 
        ELSE 0 END AS running_balance
    FROM data_bank.customer_transactions),
  
  running_balance_within_month AS (
    SELECT customer_id, txn_date, txn_month, 
      SUM(running_balance) OVER(PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS transaction_running_balance
    FROM running_balances)
  
  SELECT txn_month, SUM(transaction_running_balance) AS total_running_balance
  FROM running_balance_within_month
  GROUP BY txn_month
  ORDER BY txn_month;