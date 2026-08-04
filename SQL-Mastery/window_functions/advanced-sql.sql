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








