USE gabby;

GO
CREATE OR ALTER VIEW
  pm.teacher_goals_lockbox_wide AS
SELECT
  p.academic_year,
  p.df_employee_number,
  p.metric_bucket,
  p.metric_label,
  p.metric_name,
  p.pm_term,
  p.grade_level,
  p.is_sped_goal,
  p.[Metric Value] AS metric_value,
  p.Goal AS goal,
  p.Score AS score,
  p.[Grade-Level Weight] AS grade_level_weight,
  p.[Bucket Weight] AS bucket_weight,
  p.[Bucket Score] AS bucket_score
FROM
  (
    SELECT
      academic_year,
      df_employee_number,
      metric_bucket,
      metric_label,
      metric_name,
      pm_term,
      grade_level,
      is_sped_goal,
      measure_names,
      measure_values
    FROM
      pm.teacher_goals_lockbox
  ) AS sub PIVOT (
    MAX(measure_values) FOR measure_names IN (
      [Metric Value],
      [Goal],
      [Score],
      [Grade-Level Weight],
      [Bucket Score],
      [Bucket Weight]
    )
  ) AS p
