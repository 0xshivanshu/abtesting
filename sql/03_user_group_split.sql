-- Step 3: Randomly (and deterministically) assign each user to control or variant.
-- FARM_FINGERPRINT hashes the user_pseudo_id into a number; MOD 2 acts as a coin flip
-- that always produces the same result for the same user.

SELECT
  user_pseudo_id,
  CASE
    WHEN MOD(ABS(FARM_FINGERPRINT(user_pseudo_id)), 2) = 0 THEN 'control'
    ELSE 'variant'
  END AS ab_group
FROM (
  SELECT DISTINCT user_pseudo_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201107'
);

-- Sanity check: confirm roughly a 50/50 split
SELECT ab_group, COUNT(*) AS num_users
FROM (
  SELECT
    user_pseudo_id,
    CASE
      WHEN MOD(ABS(FARM_FINGERPRINT(user_pseudo_id)), 2) = 0 THEN 'control'
      ELSE 'variant'
    END AS ab_group
  FROM (
    SELECT DISTINCT user_pseudo_id
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201107'
  )
)
GROUP BY ab_group;
