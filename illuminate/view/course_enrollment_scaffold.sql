CREATE OR ALTER VIEW
  illuminate_dna_assessments.course_enrollment_scaffold AS
SELECT
  student_id,
  academic_year,
  entry_date,
  leave_date,
  grade_level_id,
  credittype,
  subject_area,
  is_advanced_math_student
FROM
  gabby.illuminate_dna_assessments.course_enrollment_scaffold_current_static
UNION ALL
SELECT
  student_id,
  academic_year,
  entry_date,
  leave_date,
  grade_level_id,
  credittype,
  subject_area,
  is_advanced_math_student
FROM
  gabby.illuminate_dna_assessments.course_enrollment_scaffold_archive
