CREATE OR ALTER VIEW
  illuminate_groups.student_groups AS
SELECT
  s.local_student_id,
  g.group_id,
  g.group_name,
  aff.start_date,
  aff.end_date,
  aff.eligibility_start_date,
  aff.eligibility_end_date
FROM
  gabby.illuminate_groups.group_student_aff AS aff
  INNER JOIN gabby.illuminate_groups.groups AS g ON (aff.group_id = g.group_id)
  INNER JOIN gabby.illuminate_public.students AS s ON (aff.student_id = s.student_id)
WHERE
  aff.start_date >= DATEFROMPARTS(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
