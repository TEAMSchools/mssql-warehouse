USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_state_test_scores AS

SELECT student_number      
      ,test_type
      ,subject
      ,test_name
      ,scale_score
      ,proficiency_level
      ,is_proficient      
      ,CONCAT(academic_year, '-', (academic_year + 1)) AS academic_year

      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, subject
           ORDER BY academic_year) AS test_index
FROM
    (
     SELECT co.student_number
           ,co.academic_year
           ,'PARCC' AS test_type      
        
           ,CASE WHEN parcc.subject = 'English Language Arts/Literacy' THEN 'ELA' ELSE 'Math' END AS subject
           ,parcc.subject COLLATE SQL_Latin1_General_CP1_CI_AS AS test_name
           ,parcc.test_scale_score AS scale_score
           ,CASE
             WHEN parcc.test_performance_level = 5 THEN 'Exceeded Expectations'
             WHEN parcc.test_performance_level = 4 THEN 'Met Expectations'
             WHEN parcc.test_performance_level = 3 THEN 'Approached Expectations'
             WHEN parcc.test_performance_level = 2 THEN 'Partially Met Expectations'
             WHEN parcc.test_performance_level = 1 THEN 'Did Not Yet Meet Expectations'
            END AS proficiency_level
           ,CASE
             WHEN parcc.test_performance_level >= 4 THEN 1
             WHEN parcc.test_performance_level < 4 THEN 0
            END AS is_proficient    
     FROM gabby.powerschool.cohort_identifiers_static co 
     JOIN gabby.parcc.summative_record_file parcc
       ON co.state_studentnumber = parcc.state_student_identifier
      AND co.academic_year = parcc.academic_year
     WHERE co.academic_year >= 2014  
       AND co.rn_year = 1

     UNION ALL

     SELECT co.student_number      
           ,co.academic_year
        
           ,nj.test_type
           ,nj.subject
           ,nj.subject AS test_name
           ,nj.scaled_score AS scale_score
           ,nj.performance_level AS proficiency_level
           ,CASE
             WHEN nj.scaled_score >= 200 THEN 1
             WHEN nj.scaled_score < 200 THEN 0
            END AS is_proficient
     FROM gabby.powerschool.cohort_identifiers_static co
     JOIN gabby.njsmart.all_state_assessments nj 
       ON co.student_number = nj.local_student_id
      AND co.academic_year = nj.academic_year 
     WHERE co.rn_year = 1
    ) sub