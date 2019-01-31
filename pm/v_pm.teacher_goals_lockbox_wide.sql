USE gabby
GO

CREATE OR ALTER VIEW gabby.pm.teacher_goals_lockbox_wide AS

SELECT *
FROM

(SELECT academic_year
      ,df_employee_number
      ,metric_bucket
      ,metric_label
      ,metric_name
      ,pm_term
      ,measure_names
      ,measure_values
FROM pm.teacher_goals_lockbox
) AS SourceTable PIVOT(
  MAX(measure_values)
  FOR measure_names IN ([Metric Value]
                       ,[Goal]
                       ,[Score]
                       ,[Grade-Level Weight]
                       ,[Bucket Score]
                       ,[Bucket Weight])) AS PivotTable;