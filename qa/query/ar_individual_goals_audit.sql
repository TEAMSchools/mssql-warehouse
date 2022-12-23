SELECT
  student_number,
  reporting_term,
  adjusted_goal,
  adjusted_goal_tbl
FROM
  (
    SELECT
      vw.student_number,
      vw.reporting_term,
      vw.adjusted_goal,
      tbl.adjusted_goal AS adjusted_goal_tbl
    FROM
      gabby.renaissance.ar_individualized_goals_long AS vw
      FULL JOIN gabby.renaissance.ar_individualized_goals_long_static AS tbl ON (
        vw.student_number = tbl.student_number
        AND vw.reporting_term = tbl.reporting_term
      )
  ) AS sub
WHERE
  ISNULL(adjusted_goal, '') != ISNULL(adjusted_goal_tbl, '')
