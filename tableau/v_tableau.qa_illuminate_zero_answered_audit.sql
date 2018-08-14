USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_illuminate_zero_answered_audit AS

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status

      ,ovr.date_taken
      ,ovr.percent_correct   
      ,ovr.answered
      ,ovr.number_of_questions
      
      ,a.assessment_id
      ,a.title
      ,a.administered_at

      ,dsc.code_translation AS scope
      
      ,dsu.code_translation AS subject_area

      ,dt.alt_name AS term_name
      ,dt.start_date
      ,dt.end_date

      ,att.att_code
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.illuminate_public.students s
  ON co.student_number = s.local_student_id
JOIN gabby.illuminate_dna_assessments.agg_student_responses ovr
  ON s.student_id = ovr.student_id
 AND ovr.answered = 0
JOIN gabby.illuminate_dna_assessments.assessments a
  ON ovr.assessment_id = a.assessment_id
 AND co.academic_year = a.academic_year_clean
LEFT JOIN gabby.illuminate_codes.dna_scopes dsc
  ON a.code_scope_id = dsc.code_id
LEFT JOIN gabby.illuminate_codes.dna_subject_areas dsu
  ON a.code_subject_area_id = dsu.code_id
LEFT JOIN gabby.reporting.reporting_terms dt
  ON co.schoolid = dt.schoolid
 AND co.academic_year = dt.academic_year
 AND a.administered_at BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT' 
LEFT JOIN gabby.powerschool.ps_attendance_daily att
  ON co.studentid = att.studentid
 AND co.db_name = att.db_name
 AND ovr.date_taken = att.att_date
 AND att.att_code LIKE 'A%'
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.enroll_status = 0