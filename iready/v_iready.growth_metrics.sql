USE gabby
GO

CREATE OR ALTER VIEW iready.growth_metrics AS

WITH baseline AS(
  SELECT dr.student_id AS student_number
        ,dr.academic_year
        ,dr.[percentile] AS baseline_percentile
        ,CAST(dr.overall_scale_score AS FLOAT) AS baseline_scale
        ,CASE 
          WHEN dr._file LIKE '%_ela%' THEN 'Reading'
          WHEN dr._file LIKE '%_math%' THEN 'Math'
          ELSE NULL
         END AS [subject]
  FROM gabby.iready.diagnostic_results dr
  WHERE dr.baseline_diagnostic_y_n_ = 'Y'
 )

,recent AS(
  SELECT dr.student_id AS student_number
        ,dr.academic_year
        ,dr.[percentile] AS recent_percentile
        ,CAST(dr.overall_scale_score AS FLOAT) AS recent_scale
        ,CASE 
          WHEN dr._file LIKE '%_ela%' THEN 'Reading'
          WHEN dr._file LIKE '%_math%' THEN 'Math'
          ELSE NULL 
         END AS [subject]
        ,dr.percent_progress_to_annual_typical_growth_
        ,dr.percent_progress_to_annual_stretch_growth_
        ,dr.diagnostic_gain
        ,dr.annual_typical_growth_measure
        ,dr.annual_stretch_growth_measure
  FROM gabby.iready.diagnostic_results dr
  WHERE dr.baseline_diagnostic_y_n_ = 'N'
    AND dr.most_recent_diagnostic_y_n_ = 'Y'
 )

SELECT bl.student_number
      ,LEFT(bl.academic_year, 4) AS academic_year
      ,bl.[subject]
      ,bl.baseline_scale
      ,bl.baseline_percentile
      ,re.recent_scale
      ,re.recent_percentile
      ,re.annual_typical_growth_measure
      ,re.annual_stretch_growth_measure
      ,re.diagnostic_gain AS diagnostic_gain
      ,re.percent_progress_to_annual_typical_growth_ AS progress_typical
      ,re.percent_progress_to_annual_stretch_growth_ AS progress_stretch
FROM baseline bl
LEFT JOIN recent re
  ON bl.student_number = re.student_number
 AND bl.academic_year = re.academic_year
 AND bl.[subject] = re.[subject]
LEFT JOIN gabby.iready.diagnostic_and_instruction di
  ON bl.student_number = di.student_id
 AND bl.[subject] = di.[subject]
 AND bl.academic_year = di.academic_year