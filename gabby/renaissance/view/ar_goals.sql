CREATE OR ALTER VIEW
  renaissance.ar_goals AS
SELECT
  student_number,
  academic_year,
  reporting_term,
  words_goal,
  points_goal
FROM
  renaissance.ar_goals_current_static
UNION ALL
SELECT
  student_number,
  academic_year,
  reporting_term,
  words_goal,
  points_goal
FROM
  renaissance.ar_goals_archive
