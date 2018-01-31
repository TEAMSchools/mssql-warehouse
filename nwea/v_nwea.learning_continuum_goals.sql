USE gabby
GO

CREATE OR ALTER VIEW nwea.learning_continuum_goals AS

WITH long_data AS (
  SELECT student_id
        ,academic_year
        ,term
        ,measurement_scale
        ,test_id
        ,test_name
        ,CONVERT(INT,SUBSTRING(field, 6, 1)) AS goal_number
        ,SUBSTRING(field, 8, 10) AS goal_field
        ,value
  FROM
      (
       SELECT student_id
             ,academic_year
             ,term
             ,measurement_scale                          
             ,test_id
             ,test_name
             ,CONVERT(VARCHAR(50), goal_1_adjective) AS goal_1_adjective
             ,CONVERT(VARCHAR(50), goal_1_name) AS goal_1_name
             ,CONVERT(VARCHAR(50), goal_1_range) AS goal_1_range
             ,CONVERT(VARCHAR(50), goal_1_rit_score) AS goal_1_rit_score
             ,CONVERT(VARCHAR(50), goal_2_adjective) AS goal_2_adjective
             ,CONVERT(VARCHAR(50), goal_2_name) AS goal_2_name
             ,CONVERT(VARCHAR(50), goal_2_range) AS goal_2_range
             ,CONVERT(VARCHAR(50), goal_2_rit_score) AS goal_2_rit_score
             ,CONVERT(VARCHAR(50), goal_3_adjective) AS goal_3_adjective
             ,CONVERT(VARCHAR(50), goal_3_name) AS goal_3_name
             ,CONVERT(VARCHAR(50), goal_3_range) AS goal_3_range
             ,CONVERT(VARCHAR(50), goal_3_rit_score) AS goal_3_rit_score
             ,CONVERT(VARCHAR(50), goal_4_adjective) AS goal_4_adjective
             ,CONVERT(VARCHAR(50), goal_4_name) AS goal_4_name
             ,CONVERT(VARCHAR(50), goal_4_range) AS goal_4_range
             ,CONVERT(VARCHAR(50), goal_4_rit_score) AS goal_4_rit_score
             ,CONVERT(VARCHAR(50), goal_5_adjective) AS goal_5_adjective
             ,CONVERT(VARCHAR(50), goal_5_name) AS goal_5_name
             ,CONVERT(VARCHAR(50), goal_5_range) AS goal_5_range
             ,CONVERT(VARCHAR(50), goal_5_rit_score) AS goal_5_rit_score
             ,CONVERT(VARCHAR(50), goal_6_adjective) AS goal_6_adjective
             ,CONVERT(VARCHAR(50), goal_6_name) AS goal_6_name
             ,CONVERT(VARCHAR(50), goal_6_range) AS goal_6_range
             ,CONVERT(VARCHAR(50), goal_6_rit_score) AS goal_6_rit_score             
       FROM gabby.nwea.assessment_result_identifiers
      ) sub
  UNPIVOT(
    value
    FOR field IN (goal_1_adjective
                 ,goal_1_name
                 ,goal_1_range
                 ,goal_1_rit_score
                 ,goal_2_adjective
                 ,goal_2_name
                 ,goal_2_range
                 ,goal_2_rit_score
                 ,goal_3_adjective
                 ,goal_3_name
                 ,goal_3_range
                 ,goal_3_rit_score
                 ,goal_4_adjective
                 ,goal_4_name
                 ,goal_4_range
                 ,goal_4_rit_score
                 ,goal_5_adjective
                 ,goal_5_name
                 ,goal_5_range
                 ,goal_5_rit_score
                 ,goal_6_adjective
                 ,goal_6_name
                 ,goal_6_range
                 ,goal_6_rit_score)
   ) u
 )

SELECT student_id AS student_number
      ,academic_year
      ,term
      ,measurement_scale
      ,test_id
      ,test_name
      ,goal_number
      ,name
      ,CONVERT(INT,rit_score) AS ritscore
      ,range
      ,adjective
FROM long_data
PIVOT(
  MAX(value)
  FOR goal_field IN ([name]
                    ,[rit_score]
                    ,[range]
                    ,[adjective])
 ) p