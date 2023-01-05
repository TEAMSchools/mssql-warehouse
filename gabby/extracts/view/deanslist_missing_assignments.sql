CREATE OR ALTER VIEW
  extracts.deanslist_missing_assignments AS
SELECT
  student_number,
  grade_category,
  assign_name,
  assign_date,
  course_name,
  teacher_name
FROM
  tableau.gradebook_assignment_detail
WHERE
  academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND ismissing = 1
  AND finalgrade_category = 'Q'
