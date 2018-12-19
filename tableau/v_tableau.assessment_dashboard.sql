USE gabby
GO

CREATE OR ALTER VIEW tableau.assessment_dashboard AS

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid AS schoolid     
      ,co.region
      ,co.grade_level
      ,co.team      
      ,co.enroll_status
      ,co.cohort
      ,co.iep_status
      ,co.lep_status
      ,co.c_504_status
      ,co.is_pathways

      ,asr.assessment_id
      ,asr.title
      ,asr.scope            
      ,asr.subject_area
      ,asr.term_administered
      ,asr.administered_at
      ,asr.term_taken      
      ,asr.date_taken
      ,asr.response_type      
      ,asr.module_type      
      ,asr.module_number      
      ,asr.standard_code
      ,asr.standard_description
      ,asr.domain_description
      ,asr.percent_correct
      ,asr.is_mastery
      ,asr.performance_band_number      
      ,asr.is_replacement
            
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.teacher_name
        ELSE enr.teacher_name
       END AS teacher_name      
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.course_name
        ELSE enr.course_name
       END AS course_name
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.expression
        ELSE enr.expression
       END AS expression
      ,CASE
        WHEN (co.grade_level <= 4 OR co.reporting_schoolid = 732585074) THEN hr.section_number
        ELSE enr.section_number
       END AS section_number
FROM gabby.powerschool.cohort_identifiers_static co 
JOIN gabby.illuminate_dna_assessments.agg_student_responses_all asr
  ON co.student_number = asr.local_student_id
 AND co.academic_year = asr.academic_year
LEFT JOIN gabby.powerschool.course_enrollments_static enr
  ON co.student_number = enr.student_number
 AND co.academic_year = enr.academic_year
 AND co.db_name = enr.db_name
 AND asr.subject_area = enr.illuminate_subject COLLATE Latin1_General_BIN
 AND enr.course_enroll_status = 0 
 AND enr.section_enroll_status = 0 
 AND enr.rn_illuminate_subject = 1
LEFT JOIN gabby.powerschool.course_enrollments_static hr
  ON co.student_number = hr.student_number
 AND co.academic_year = hr.academic_year
 AND co.db_name = hr.db_name
 AND hr.course_number = 'HR'    
 AND hr.course_enroll_status = 0 
 AND hr.section_enroll_status = 0 
 AND hr.rn_subject = 1
WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
  AND co.reporting_schoolid NOT IN (5173, 999999) /* exclude OoD Placements */
  AND co.rn_year = 1