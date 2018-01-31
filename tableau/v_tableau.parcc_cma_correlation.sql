USE gabby
GO

CREATE OR ALTER VIEW tableau.parcc_cma_correlation AS

SELECT co.reporting_schoolid AS schoolid
      ,co.academic_year
      ,co.grade_level      
      ,co.student_number
      ,co.lastfirst
      ,co.iep_status
      ,co.enroll_status               

      ,asr.assessment_id
      ,asr.title
      ,asr.scope            
      ,asr.subject_area 
      ,asr.module_number
      ,asr.module_type     
      ,asr.percent_correct
      ,asr.performance_band_number

      ,parcc.test_code AS parcc_test_code
      ,parcc.test_scale_score AS parcc_test_scale_score
      ,parcc.test_performance_level AS parcc_test_performance_level
FROM gabby.powerschool.cohort_identifiers_static co 
JOIN gabby.illuminate_dna_assessments.agg_student_responses_all asr
  ON co.student_number = asr.local_student_id
 AND co.academic_year = asr.academic_year
 AND asr.scope IN ('CMA - End-of-Module','CMA - Mid-Module')
 AND asr.subject_area IN ('Text Study','Mathematics')
 AND asr.is_replacement = 0
 AND asr.response_type = 'O' 
JOIN gabby.parcc.summative_record_file_clean parcc
  ON co.student_number = parcc.local_student_identifier
 AND co.academic_year = parcc.academic_year
 AND asr.subject_area = CASE WHEN parcc.subject = 'English Language Arts/Literacy' THEN 'Text Study' ELSE 'Mathematics' END
WHERE co.rn_year = 1 
  AND co.academic_year >= 2015