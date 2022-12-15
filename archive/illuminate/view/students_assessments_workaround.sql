USE gabby GO
CREATE OR ALTER VIEW
  illuminate_dna_assessments.students_assessments_workaround AS
SELECT
  c.student_assessment_id,
  c.assessment_id,
  c.student_id,
  c.date_taken
FROM
  gabby.illuminate_dna_assessments.students_assessments_workaround_current_static AS c
UNION ALL
SELECT
  a.student_assessment_id,
  a.assessment_id,
  a.student_id,
  a.date_taken
FROM
  gabby.illuminate_dna_assessments.students_assessments_workaround_archive AS a
