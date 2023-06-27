CREATE OR ALTER VIEW
  tableau.marketing_facebook_page AS
SELECT
  CAST([date] AS DATE) AS [date],
  page_id,
  page_fans,
  page_fan_adds,
  page_fan_removes
FROM
  kipptaf.facebook_pages.daily_page_metrics_total
