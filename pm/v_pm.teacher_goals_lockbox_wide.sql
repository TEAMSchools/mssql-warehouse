USE gabby;
GO

CREATE OR ALTER VIEW pm.teacher_goals_lockbox_wide AS

SELECT p.academic_year
      ,p.df_employee_number
      ,p.metric_bucket
      ,p.metric_label
      ,p.metric_name
      ,p.pm_term
      
      ,p.[Metric Value]
      ,p.Goal
      ,p.Score      
      ,p.[Grade-Level Weight]
      ,p.[Bucket Weight]
      ,p.[Bucket Score]
FROM
    (
     SELECT academic_year
           ,df_employee_number
           ,metric_bucket
           ,metric_label
           ,metric_name
           ,pm_term
           ,measure_names
           ,measure_values
     FROM pm.teacher_goals_lockbox
    ) sub
PIVOT (
  MAX(measure_values)
  FOR measure_names IN ([Metric Value], [Goal], [Score], [Grade-Level Weight], [Bucket Score], [Bucket Weight])
 ) AS p