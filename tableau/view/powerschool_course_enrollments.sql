USE gabby GO
CREATE OR ALTER VIEW
  tableau.powerschool_course_enrollments AS
SELECT
  student_number,
  schoolid,
  course_name,
  section_number,
  expression,
  teacher_name
FROM
  gabby.powerschool.course_enrollments_current_static
WHERE
  course_enroll_status = 0
  AND section_enroll_status = 0
