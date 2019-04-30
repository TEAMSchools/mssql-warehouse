USE gabby
GO

CREATE OR ALTER VIEW finance.financial_model_clean AS

SELECT region
      ,metric
      ,DATENAME(MONTH, snapshot_date) AS month
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
FROM gabby.finance.financial_model
WHERE _fivetran_deleted = 0