-- Step 1: Explore what event types exist in the dataset, for a single day.
-- Purpose: get familiar with the data before building anything.

SELECT
  event_name,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS distinct_users
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201101`
GROUP BY
  event_name
ORDER BY
  event_count DESC;
