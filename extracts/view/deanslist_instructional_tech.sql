CREATE OR ALTER VIEW
  extracts.deanslist_instructional_tech AS
SELECT
  student_number,
  academic_year,
  'Accelerated Reader' AS it_program,
  words AS progress,
  words_goal AS goal,
  stu_status_words AS goal_status,
  CASE
    WHEN reporting_term = 'ARY' THEN 'Y1'
    ELSE REPLACE(reporting_term, 'AR', 'Q')
  END AS term
FROM
  gabby.renaissance.ar_progress_to_goals
WHERE
  academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
