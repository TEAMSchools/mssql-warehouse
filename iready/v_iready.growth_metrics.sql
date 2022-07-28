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
  WHERE dr.diagnostic_used_to_establish_growth_measures_y_n_ = 'Y'
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
  FROM gabby.iready.diagnostic_results dr
  WHERE dr.diagnostic_used_to_establish_growth_measures_y_n_ = 'N'
    AND dr.most_recent_diagnostic_y_n_ = 'Y'
 )

SELECT bl.student_number
      ,LEFT(bl.academic_year, 4) AS academic_year
      ,bl.[subject]
      ,bl.baseline_scale
      ,bl.baseline_percentile
      ,re.recent_scale
      ,re.recent_percentile
      ,di.annual_typical_growth_measure
      ,di.annual_stretch_growth_measure
      ,CASE 
        WHEN re.recent_scale - bl.baseline_scale < 0 THEN 0
        WHEN re.recent_scale - bl.baseline_scale >= 0 THEN re.recent_scale - bl.baseline_scale
        ELSE NULL 
       END AS diagnostic_gain
      ,CASE 
        WHEN re.recent_scale - bl.baseline_scale <= 0 THEN 0
        WHEN re.recent_scale - bl.baseline_scale > 0 THEN ROUND((re.recent_scale - bl.baseline_scale) / CAST(di.annual_typical_growth_measure AS FLOAT), 2)
        ELSE NULL 
       END AS progress_typical
      ,CASE 
        WHEN re.recent_scale - bl.baseline_scale <= 0 THEN 0
        WHEN re.recent_scale - bl.baseline_scale > 0 THEN ROUND((re.recent_scale - bl.baseline_scale) / CAST(di.annual_stretch_growth_measure AS FLOAT), 2)
        ELSE NULL 
       END AS progress_stretch
FROM baseline bl
LEFT JOIN recent re
  ON bl.student_number = re.student_number
 AND bl.academic_year = re.academic_year
 AND bl.[subject] = re.[subject]
LEFT JOIN gabby.iready.diagnostic_and_instruction di
  ON bl.student_number = di.student_id
 AND bl.[subject] = di.[subject]
 AND bl.academic_year = di.academic_year
