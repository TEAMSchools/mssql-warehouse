USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_act_scores AS

SELECT student_number
      ,academic_year
      ,[scale_score_act1]
      ,[scale_score_act2]
      ,[scale_score_act3]
      ,[scale_score_act4]
      ,[scale_score_act5]
      ,[scale_score_act6]
      ,[scale_score_act7]
FROM
    (
     SELECT student_number
           ,academic_year      
           ,CONCAT('scale_score_', LOWER(REPLACE(time_per_name,'-',''))) AS field
           ,scale_score
     FROM gabby.act.test_prep_scores
     WHERE subject_area = 'Composite'
       AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    ) sub
PIVOT(
  MAX(scale_score)
  FOR field IN ([scale_score_act1]
               ,[scale_score_act2]
               ,[scale_score_act3]
               ,[scale_score_act4]
               ,[scale_score_act5]
               ,[scale_score_act6]
               ,[scale_score_act7])
 ) p