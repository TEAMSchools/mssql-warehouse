USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_cma_entry_audit AS

SELECT asr.local_student_id AS student_number      
      ,asr.term_administered AS term      
      ,asr.assessment_id
      ,asr.title
      ,asr.administered_at
      ,asr.subject_area
      ,asr.scope   
      ,asr.module_type
      ,asr.module_number
      ,asr.percent_correct      
      ,asr.is_replacement      

      ,co.lastfirst
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status      
FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr
JOIN gabby.powerschool.cohort_identifiers_static co
  ON asr.local_student_id = co.student_number
 AND asr.academic_year = co.academic_year
 AND co.rn_year = 1
WHERE asr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND asr.response_type = 'O'
  AND asr.module_type IS NOT NULL
  AND asr.is_replacement = 0