-- Step 6: Two-proportion z-test comparing control vs variant conversion rates.
-- Requires `user_funnel_synthetic` view to exist first (from 05_synthetic_lift.sql).
--
-- Save this query's output as a view named `ab_test_stats`.
-- Replace `your_project.your_dataset.user_funnel_synthetic` with your actual path.

WITH stats AS (
  SELECT
    ab_group,
    COUNT(*) AS n,
    SUM(synthetic_purchase) AS conversions,
    SUM(synthetic_purchase) / COUNT(*) AS rate
  FROM
    `your_project.your_dataset.user_funnel_synthetic`
  GROUP BY
    ab_group
),

pivoted AS (
  SELECT
    MAX(CASE WHEN ab_group = 'control' THEN n END) AS n_control,
    MAX(CASE WHEN ab_group = 'control' THEN conversions END) AS conv_control,
    MAX(CASE WHEN ab_group = 'control' THEN rate END) AS rate_control,
    MAX(CASE WHEN ab_group = 'variant' THEN n END) AS n_variant,
    MAX(CASE WHEN ab_group = 'variant' THEN conversions END) AS conv_variant,
    MAX(CASE WHEN ab_group = 'variant' THEN rate END) AS rate_variant
  FROM
    stats
)

SELECT
  rate_control,
  rate_variant,
  rate_variant - rate_control AS lift,
  (conv_control + conv_variant) / (n_control + n_variant) AS pooled_rate,
  SQRT(
    ((conv_control + conv_variant) / (n_control + n_variant))
    * (1 - (conv_control + conv_variant) / (n_control + n_variant))
    * (1.0 / n_control + 1.0 / n_variant)
  ) AS standard_error,
  (rate_variant - rate_control) /
  SQRT(
    ((conv_control + conv_variant) / (n_control + n_variant))
    * (1 - (conv_control + conv_variant) / (n_control + n_variant))
    * (1.0 / n_control + 1.0 / n_variant)
  ) AS z_score
FROM
  pivoted;

-- Reading the result: a z_score above 1.96 (or below -1.96) corresponds to
-- statistical significance at the standard p < 0.05 threshold.
