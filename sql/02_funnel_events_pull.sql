-- Step 2: Pull just the 5 funnel events, across a 7-day window.
-- _TABLE_SUFFIX restricts the wildcard scan to Nov 1-7 only (cost control).

SELECT
  event_date,
  event_name,
  user_pseudo_id,
  event_timestamp
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20201101' AND '20201107'
  AND event_name IN ('page_view', 'view_item', 'add_to_cart', 'begin_checkout', 'purchase')
ORDER BY
  user_pseudo_id, event_timestamp;
