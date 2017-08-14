USE gabby
GO

ALTER VIEW act.test_prep_scores_wide AS

SELECT student_number
      ,academic_year
      ,administration_round
      ,[english]
      ,[mathematics]
      ,[reading]
      ,[science]
      ,[composite]
      ,CASE WHEN [composite] >= 22 THEN 1.0 ELSE 0.0 END AS is_22
      ,CASE WHEN [composite] >= 25 THEN 1.0 ELSE 0.0 END AS is_25
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year
           ORDER BY administered_at DESC) AS rn_curr
FROM
    (
     SELECT student_number
           ,academic_year
           ,administration_round
           ,administered_at
           ,subject_area
           ,scale_score
     FROM gabby.act.test_prep_scores 
     WHERE rn_dupe = 1
    ) sub
PIVOT(
  MAX(scale_score)
  FOR subject_area IN ([english]
                      ,[mathematics]
                      ,[reading]
                      ,[science]
                      ,[composite])
 ) p