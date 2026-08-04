# Advanced SQL
# Repeated Payments
/*
 identifying any payments made at the same merchant with the same credit card for the same amount within 10 minutes
 of each other and reporting the count of such repeated payments.
*/

WITH payments AS (
  SELECT 
    merchant_id, 
    EXTRACT(EPOCH FROM transaction_timestamp - 
      LAG(transaction_timestamp) OVER(
        PARTITION BY merchant_id, credit_card_id, amount 
        ORDER BY transaction_timestamp)
    )/60 AS minute_difference 
  FROM transactions) 

SELECT COUNT(merchant_id) AS payment_count
FROM payments 
WHERE minute_difference <= 10;


# Median Google Search Frequency 
/*
Google’s Marketing Team needed to add a simple statistic to their upcoming Superbowl Ad: the median number of searches made per year. 
You were given a summary table that tells you the number of searches made last year, write a query to report the median searches made per user.
*/
WITH expanded AS (
  SELECT searches
  FROM search_frequency, generate_series(1, num_users)
)
SELECT 
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY searches)::DECIMAL, 1) AS median
FROM expanded;

# another code
WITH searches_expanded AS (
  SELECT searches
  FROM search_frequency
  GROUP BY 
    searches, 
    GENERATE_SERIES(1, num_users))

SELECT 
  ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (
    ORDER BY searches)::DECIMAL, 1) AS  median
FROM searches_expanded;

# Monthly Merchant Balance
/*
Write a query to print the cumulative balance of the merchant account at the end of each day, 
with the total balance reset back to zero at the end of the month. Output the transaction date and cumulative balance.
*/
SELECT 
    DATE_TRUNC('day', transaction_date) AS transaction_day,
    SUM(SUM(CASE WHEN type = 'deposit' THEN amount ELSE -amount END)) OVER (
        PARTITION BY DATE_TRUNC('month', transaction_date) 
        ORDER BY DATE_TRUNC('day', transaction_date)
    ) AS balance
FROM transactions
GROUP BY DATE_TRUNC('day', transaction_date), DATE_TRUNC('month', transaction_date)
ORDER BY transaction_day;
 

# Server Utilization Time
# Write a query that calculates the total time that the fleet of servers was running. The output should be in units of full days.


WITH running_time 
AS (
  SELECT
    server_id,
    session_status,
    status_time AS start_time,
    LEAD(status_time) OVER (
      PARTITION BY server_id
      ORDER BY status_time) AS stop_time
  FROM server_utilization
)

SELECT 
# DATE_PART('days', ...): Extracts just the total number of full days from the final accumulated time interval.
  DATE_PART('days', JUSTIFY_HOURS(SUM(stop_time - start_time))) AS total_uptime_days   
# JUSTIFY_HOURS(...): Adjusts the total interval so that accumulated hours roll up cleanly into days (e.g., turning 48 hours into 2 days).
FROM running_time
WHERE session_status = 'start'
  AND stop_time IS NOT NULL;



 
 
 
 