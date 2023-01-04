USE gabby GO
CREATE OR ALTER VIEW
  iready.growth_metrics AS
WITH
  baseline AS (
    SELECT
      student_id AS student_number,
      academic_year,
      [percentile] AS baseline_percentile,
      CAST(overall_scale_score AS FLOAT) AS baseline_scale,
      CASE
        WHEN _file LIKE '%_ela%' THEN 'Reading'
        WHEN _file LIKE '%_math%' THEN 'Math'
      END AS [subject]
    FROM
      gabby.iready.diagnostic_results
    WHERE
      baseline_diagnostic_y_n_ = 'Y'
  ),
  recent AS (
    SELECT
      student_id AS student_number,
      academic_year,
      [percentile] AS recent_percentile,
      CAST(overall_scale_score AS FLOAT) AS recent_scale,
      CASE
        WHEN _file LIKE '%_ela%' THEN 'Reading'
        WHEN _file LIKE '%_math%' THEN 'Math'
      END AS [subject],
      percent_progress_to_annual_typical_growth_,
      percent_progress_to_annual_stretch_growth_,
      diagnostic_gain,
      annual_typical_growth_measure,
      annual_stretch_growth_measure
    FROM
      gabby.iready.diagnostic_results
    WHERE
      baseline_diagnostic_y_n_ = 'N'
      AND most_recent_diagnostic_y_n_ = 'Y'
  )
SELECT
  bl.student_number,
  LEFT(bl.academic_year, 4) AS academic_year,
  bl.[subject],
  bl.baseline_scale,
  bl.baseline_percentile,
  re.recent_scale,
  re.recent_percentile,
  re.annual_typical_growth_measure,
  re.annual_stretch_growth_measure,
  re.diagnostic_gain AS diagnostic_gain,
  re.percent_progress_to_annual_typical_growth_ AS progress_typical,
  re.percent_progress_to_annual_stretch_growth_ AS progress_stretch
FROM
  baseline AS bl
  LEFT JOIN recent AS re ON (
    bl.student_number = re.student_number
    AND bl.academic_year = re.academic_year
    AND bl.[subject] = re.[subject]
  )
  LEFT JOIN gabby.iready.diagnostic_and_instruction AS di ON (
    bl.student_number = di.student_id
    AND bl.[subject] = di.[subject]
    AND bl.academic_year = di.academic_year
  )
