# A/B Experimentation and Conversion Funnel Evaluation

**Tools:** SQL (BigQuery) · Power BI
**Data source:** [GA4 Obfuscated Sample E-commerce Dataset](https://console.cloud.google.com/bigquery(product)/analytics-hub/exchanges) - `bigquery-public-data.ga4_obfuscated_sample_ecommerce`

## Project Overview

This project simulates a controlled A/B experiment on top of real Google Analytics 4 (GA4)
e-commerce event data from the Google Merchandise Store. It builds a full pipeline -
from raw event data to a statistically validated conversion lift to a reporting dashboard -
mirroring how a data/analytics team would evaluate a product experiment end-to-end.

**Funnel stages analyzed:**
`page_view → view_item → add_to_cart → begin_checkout → purchase`

## Methodology Note (read this first)

The GA4 public dataset reflects **real user behavior**, but it does not contain an actual
A/B test - there is no "control" vs "variant" experience baked into the data. To build this
project:

1. Every user was **randomly and deterministically** assigned to a `control` or `variant`
   group using a hash of their `user_pseudo_id` (`FARM_FINGERPRINT`), so the same user always
   lands in the same group.
2. A **synthetic conversion lift** was applied to the `variant` group only: ~15% of variant
   users who reached checkout but did not purchase were flipped to "converted," simulating
   the effect of a real UX improvement.
3. All underlying behavioral data (page views, cart adds, checkout starts) is 100% real GA4
   data — only the group assignment and the lift are synthetic.

This is a standard, transparent technique for building experimentation portfolio projects
on top of observational data, and is disclosed here for full transparency.

## Workflow

| Step | Description | File |
|------|-------------|------|
| 1 | Explore raw event types in the dataset | `sql/01_explore_events.sql` |
| 2 | Pull the 5 funnel events across a date range | `sql/02_funnel_events_pull.sql` |
| 3 | Randomly split users into control/variant | `sql/03_user_group_split.sql` |
| 4 | Build the funnel: users reached per stage, per group | `sql/04_funnel_stage_counts.sql` |
| 5 | Apply synthetic conversion lift to variant | `sql/05_synthetic_lift.sql` |
| 6 | Two-proportion z-test (statistical validation) | `sql/06_ab_test_stats.sql` |
| 7 | Power BI dashboard | `powerbi/` (see below) |

## Results

| Metric | Control | Variant |
|---|---|---|
| Conversion rate | ~1.11% | ~1.61% |
| Lift | — | +0.50 pp (~45% relative) |
| Z-score | 3.06 | |
| P-value | ≈ 0.002 (significant at p < 0.05) | |

**Interpretation:** Variant showed a statistically significant lift in conversion rate over
Control, rejecting the null hypothesis that both experiences perform equally
(z = 3.06, p ≈ 0.002).

## Power BI Dashboard

Connects directly to the BigQuery views created in `sql/05_synthetic_lift.sql` and
`sql/06_ab_test_stats.sql`. Includes:
- Funnel visual (stage-by-stage drop-off, control vs variant)
- KPI cards: conversion rate, lift %, statistical significance
- Segment views by device/channel

See `powerbi/dashboard_notes.md` for build details.

## How to Reproduce

1. Create a Google Cloud project with BigQuery enabled (free tier is sufficient).
2. Run the SQL scripts in `sql/` in order (01 → 06), inside the BigQuery console.
3. Save the outputs of steps 05 and 06 as **views** in your own dataset.
4. Open Power BI Desktop → Get Data → Google BigQuery → connect to your project → load
   the saved views.
5. Build/import the dashboard visuals described in `powerbi/dashboard_notes.md`.

## Disclaimer

This is a portfolio/learning project. The dataset is Google's public GA4 sample e-commerce
export; no proprietary or personal data is used. The A/B test itself is synthetic, as
disclosed above.
