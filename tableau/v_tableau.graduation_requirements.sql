USE gabby
GO

CREATE OR ALTER VIEW tableau.graduation_requirements AS

WITH parcc AS ( 
  SELECT parcc.local_student_identifier         
        ,CONCAT('parcc_', LOWER(parcc.test_code)) COLLATE Latin1_General_BIN AS test_type
        ,parcc.test_scale_score AS test_score
  FROM gabby.parcc.summative_record_file_clean parcc
  WHERE parcc.test_code IN ('ELA09', 'ELA10', 'ELA11', 'ALG01', 'GEO01', 'ALG02')
 )
    
,sat AS (
  SELECT u.hs_student_id
        ,CONCAT('sat_', u.field) COLLATE Latin1_General_BIN AS test_type
        ,u.value AS test_score
  FROM
      (
       SELECT sat.hs_student_id
             ,CONVERT(FLOAT,sat.evidence_based_reading_writing) AS evidence_based_reading_writing
             ,CONVERT(FLOAT,sat.math) AS math
             ,CONVERT(FLOAT,sat.reading_test) AS reading_test
             ,CONVERT(FLOAT,sat.math_test) AS math_test
       FROM gabby.naviance.sat_scores sat
      ) sub  
  UNPIVOT(
    value
    FOR field IN (evidence_based_reading_writing
                 ,math
                 ,reading_test
                 ,math_test)
   ) u
 )

,act AS (
  SELECT ktc.student_number
        ,LEFT(st.score_type, LEN(st.score_type)  - 2) AS test_type
        ,st.score AS test_score

  FROM gabby.alumni.standardized_test_long st
  JOIN gabby.alumni.ktc_roster ktc
    ON st.contact_c = ktc.sf_contact_id

  WHERE st.test_type = 'ACT'
    AND st.score_type IN ('act_reading_c', 'act_math_c')
 )

,all_tests AS (
  SELECT parcc.local_student_identifier
        ,parcc.test_type
        ,parcc.test_score
  FROM parcc
  UNION ALL
  SELECT sat.hs_student_id
       ,sat.test_type
       ,sat.test_score
  FROM sat
  UNION ALL
  SELECT act.student_number
       ,act.test_type
       ,act.test_score
  FROM act
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.cohort
      ,co.enroll_status
      ,co.iep_status
      ,co.c_504_status
      ,co.is_retained_year
      ,co.is_retained_ever
            
      ,a.test_type
      ,a.test_score
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN all_tests a
  ON co.student_number = a.local_student_identifier
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.cohort BETWEEN gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 5