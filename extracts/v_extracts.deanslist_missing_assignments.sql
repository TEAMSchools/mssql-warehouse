USE gabby GO
CREATE OR ALTER VIEW
  extracts.deanslist_missing_assignments AS
SELECT
  a.student_number,
  a.grade_category,
  a.assign_name,
  a.assign_date,
  a.course_name,
  a.teacher_name
FROM
  gabby.tableau.gradebook_assignment_detail a
WHERE
  a.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND a.ismissing = 1
  AND a.finalgrade_category = 'Q'
