USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_cma_entry_audit AS

SELECT s.local_student_id AS student_number      
      
      ,asr.assessment_id
      ,asr.title
      ,asr.administered_at
      ,asr.subject_area
      ,asr.scope   
      ,asr.module_type
      ,asr.module_number      
      ,asr.is_replacement      
      
      ,rt.alt_name AS term      

      ,o.percent_correct

      ,co.lastfirst
      ,co.region
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status      
FROM gabby.illuminate_dna_assessments.student_assessment_scaffold_current_static asr
JOIN gabby.illuminate_public.students s
  ON asr.student_id = s.student_id
LEFT JOIN gabby.illuminate_dna_assessments.agg_student_responses o
  ON asr.student_id = o.student_id
 AND asr.assessment_id = o.assessment_id
LEFT JOIN gabby.reporting.reporting_terms rt
  ON asr.administered_at BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
 AND rt.schoolid = 0
 AND rt._fivetran_deleted = 0
JOIN gabby.powerschool.cohort_identifiers_static co
  ON s.local_student_id = co.student_number
 AND asr.academic_year = co.academic_year
 AND co.rn_year = 1
WHERE asr.module_type IS NOT NULL
  AND asr.is_replacement = 0