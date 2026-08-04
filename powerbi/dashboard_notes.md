# Power BI Dashboard — Build Notes

## Data source connection
- Connector: **Google BigQuery** (Power BI native connector)
- Import mode (not DirectQuery)
- Tables loaded:
  - `user_funnel_synthetic` — user-level funnel + synthetic conversion flag
  - `funnel_stage_counts` — users reached per funnel stage, per group
  - `ab_test_stats` — conversion rates, lift, z-score

## Suggested visuals

1. **Funnel chart** — stage-by-stage user counts, split by `ab_group`
   (built from `funnel_stage_counts`)
2. **KPI cards**:
   - Control conversion rate
   - Variant conversion rate
   - Lift (percentage points and relative %)
   - Z-score / significance flag ("Significant" if |z| > 1.96)
3. **Bar chart** — conversion rate by group, with a reference line at the
   pooled rate
4. **Table/matrix** — full stats breakdown (from `ab_test_stats`)
5. **Segment slicers** (optional, if device/geo columns are pulled in) —
   device category, country

## DAX measures (examples)

```
Conversion Rate = DIVIDE(SUM(user_funnel_synthetic[synthetic_purchase]), COUNTROWS(user_funnel_synthetic))

Is Significant = IF(ABS(SELECTEDVALUE(ab_test_stats[z_score])) > 1.96, "Yes", "No")
```

## Notes
- Add a text box on the dashboard referencing the methodology disclosure
  in the main README (synthetic variant assignment + synthetic lift).
- Keep control/variant color coding consistent across all visuals
  (e.g. grey = control, blue = variant).
