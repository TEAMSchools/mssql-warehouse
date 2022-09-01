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
             ,CAST(goal_1_adjective AS VARCHAR(125)) AS goal_1_adjective
             ,CAST(goal_1_name AS VARCHAR(125)) AS goal_1_name
             ,CAST(goal_1_range AS VARCHAR(125)) AS goal_1_range
             ,CAST(goal_1_rit_score AS VARCHAR(125)) AS goal_1_rit_score
             ,CAST(goal_2_adjective AS VARCHAR(125)) AS goal_2_adjective
             ,CAST(goal_2_name AS VARCHAR(125)) AS goal_2_name
             ,CAST(goal_2_range AS VARCHAR(125)) AS goal_2_range
             ,CAST(goal_2_rit_score AS VARCHAR(125)) AS goal_2_rit_score
             ,CAST(goal_3_adjective AS VARCHAR(125)) AS goal_3_adjective
             ,CAST(goal_3_name AS VARCHAR(125)) AS goal_3_name
             ,CAST(goal_3_range AS VARCHAR(125)) AS goal_3_range
             ,CAST(goal_3_rit_score AS VARCHAR(125)) AS goal_3_rit_score
             ,CAST(goal_4_adjective AS VARCHAR(125)) AS goal_4_adjective
             ,CAST(goal_4_name AS VARCHAR(125)) AS goal_4_name
             ,CAST(goal_4_range AS VARCHAR(125)) AS goal_4_range
             ,CAST(goal_4_rit_score AS VARCHAR(125)) AS goal_4_rit_score
       FROM nwea.assessment_result_identifiers
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
                 ,goal_4_rit_score)                 
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
      ,CAST(rit_score AS INT) AS ritscore
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