USE gabby
GO

CREATE OR ALTER VIEW tableau.assessment_dashboard AS

SELECT co.reporting_schoolid AS schoolid
      ,co.academic_year
      ,co.grade_level
      ,co.team      
      ,co.student_number
      ,co.lastfirst
      ,co.iep_status
      ,co.lep_status
      ,co.enroll_status                    

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
LEFT OUTER JOIN gabby.powerschool.course_enrollments_static enr
  ON co.studentid = enr.studentid
 AND co.yearid = enr.yearid
 AND asr.subject_area = enr.illuminate_subject
 AND enr.course_enroll_status = 0 
 AND enr.section_enroll_status = 0 
 AND enr.rn_subject = 1
LEFT OUTER JOIN gabby.powerschool.course_enrollments_static hr
  ON co.studentid = hr.studentid
 AND co.yearid = hr.yearid
 AND hr.course_number = 'HR'    
 AND hr.course_enroll_status = 0 
 AND hr.section_enroll_status = 0 
 AND hr.rn_subject = 1
WHERE co.enroll_status IN (0,3)    
  AND co.academic_year >= 2013 /* first year with Illuminate */
  AND co.reporting_schoolid NOT IN (5173, 999999) /* exclude OoD Placements */
  AND co.rn_year = 1       