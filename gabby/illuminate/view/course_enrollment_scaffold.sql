CREATE OR ALTER VIEW
  illuminate_dna_assessments.course_enrollment_scaffold AS
SELECT
  student_id,
  academic_year,
  entry_date,
  leave_date,
  grade_level_id,
  (
    credittype
    COLLATE SQL_Latin1_General_CP1_CI_AS
  ) AS credittype,
  (
    subject_area
    COLLATE SQL_Latin1_General_CP1_CI_AS
  ) AS subject_area,
  is_advanced_math_student,
  is_foundations
FROM
  illuminate_dna_assessments.course_enrollment_scaffold_current_static
UNION ALL
SELECT
  student_id,
  academic_year,
  entry_date,
  leave_date,
  grade_level_id,
  credittype,
  subject_area,
  is_advanced_math_student,
  NULL AS is_foundations -- TODO: use real col after EOY process 22-23
FROM
  illuminate_dna_assessments.course_enrollment_scaffold_archive
