USE gabby
GO

CREATE OR ALTER VIEW qa.illuminate_assessment_missing_enrollment AS

SELECT sa.student_id
      ,sa.assessment_id

      ,s.local_student_id

      ,a.administered_at
      ,a.title
      ,a.scope
      ,a.subject_area

      ,enr.cc_id
FROM gabby.illuminate_dna_assessments.students_assessments sa
JOIN gabby.illuminate_public.students s
  ON sa.student_id = s.student_id
JOIN gabby.illuminate_dna_assessments.assessments_identifiers_static a
  ON sa.assessment_id = a.assessment_id
 AND a.is_normed_scope = 1
 AND a.deleted_at IS NULL
LEFT JOIN gabby.powerschool.course_enrollments enr
  ON s.local_student_id = enr.student_number
 AND a.subject_area = enr.illuminate_subject
 AND a.administered_at BETWEEN enr.dateenrolled AND enr.dateleft
 AND enr.course_enroll_status = 0
WHERE a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND enr.cc_id IS NULL
