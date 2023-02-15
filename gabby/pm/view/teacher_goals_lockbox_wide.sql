CREATE OR ALTER VIEW
  pm.teacher_goals_lockbox_wide AS
SELECT
  academic_year,
  df_employee_number,
  metric_bucket,
  metric_label,
  metric_name,
  pm_term,
  grade_level,
  is_sped_goal,
  [Metric Value] AS metric_value,
  [Goal] AS goal,
  [Score] AS score,
  [Grade-Level Weight] AS grade_level_weight,
  [Bucket Weight] AS bucket_weight,
  [Bucket Score] AS bucket_score
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
      measure_values,
      ROW_NUMBER() OVER (
        PARTITION BY
          academic_year,
          pm_term,
          df_employee_number,
          metric_name,
          metric_label,
          grade_level,
          is_sped_goal,
          measure_names
        ORDER BY
          _modified DESC
      ) AS rn_curr
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
WHERE
  rn_curr = 1
