CREATE OR ALTER VIEW
  illuminate_matviews.ss_cube AS
SELECT
  site_id,
  academic_year,
  grade_level_id,
  [user_id],
  section_id,
  course_id,
  student_id,
  entry_date,
  leave_date,
  is_primary_teacher
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT site_id
        ,academic_year
        ,grade_level_id
        ,user_id
        ,section_id
        ,course_id
        ,student_id
        ,entry_date
        ,leave_date
        ,is_primary_teacher
  FROM matviews.ss_cube
'
  )
