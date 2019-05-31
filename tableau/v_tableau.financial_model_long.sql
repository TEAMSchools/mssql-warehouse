USE gabby
GO

CREATE OR ALTER VIEW tableau.financial_model_long AS

WITH clean_data AS (
  SELECT sub.region
        ,sub.metric
        ,sub.snapshot_month
        ,sub.snapshot_date
        ,sub.fy_17
        ,sub.fy_18
        ,sub.fy_19
        ,sub.fy_20
        ,sub.fy_21
        ,sub.fy_22
        ,sub.fy_23
        ,sub.fy_24
        ,sub.fy_25
        ,sub.fy_26
        ,sub.fy_27
        ,sub.fy_28
        ,sub.fy_29
        ,sub.fy_30
        ,sub.fy_31
        ,sub.fy_32
        ,sub.fy_33
        ,sub.fy_34
        ,sub.fy_35
  FROM
      (
       SELECT region
             ,metric
             ,DATENAME(MONTH, snapshot_date) AS snapshot_month
             ,snapshot_date
             ,fy_17
             ,fy_18
             ,fy_19
             ,fy_20
             ,fy_21
             ,fy_22
             ,fy_23
             ,fy_24
             ,fy_25
             ,fy_26
             ,fy_27
             ,fy_28
             ,fy_29
             ,fy_30
             ,fy_31
             ,fy_32
             ,fy_33
             ,fy_34
             ,fy_35
             ,ROW_NUMBER() OVER(
                PARTITION BY region, metric, DATENAME(MONTH, snapshot_date)
                  ORDER BY snapshot_date DESC) AS rn_month
       FROM gabby.finance.financial_model
       WHERE _fivetran_deleted = 0
      ) sub
  WHERE sub.rn_month = 1
 )

SELECT u.region
      ,CONVERT(INT,'20' + RIGHT(u.field, 2)) AS fiscal_year
      ,u.snapshot_month
      ,u.snapshot_date

      ,u.metric
      ,u.value
FROM clean_data
UNPIVOT(
  value
  FOR field IN (fy_17
               ,fy_18
               ,fy_19
               ,fy_20
               ,fy_21
               ,fy_22
               ,fy_23
               ,fy_24
               ,fy_25
               ,fy_26
               ,fy_27
               ,fy_28
               ,fy_29
               ,fy_30
               ,fy_31
               ,fy_32
               ,fy_33
               ,fy_34
               ,fy_35)
 ) u