CREATE OR ALTER VIEW
  illuminate_dna_assessments.students_assessments_workaround_current AS
SELECT
  student_assessment_id,
  assessment_id,
  student_id,
  date_taken
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT student_assessment_id
        ,assessment_id
        ,student_id
        ,date_taken
  FROM dna_assessments.students_assessments
  WHERE date_taken >= ''2018-07-01''
'
  )
