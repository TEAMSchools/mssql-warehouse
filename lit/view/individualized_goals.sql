CREATE OR ALTER VIEW
  lit.individualized_goals AS
SELECT
  student_number,
  academic_year,
  test_round,
  goal,
  lvl_num
FROM
  gabby.lit.individualized_goals_current AS g
WHERE
  g.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
UNION ALL
SELECT
  CAST(student_number AS INT) AS student_number,
  CAST(academic_year AS INT) AS academic_year,
  CAST(test_round AS VARCHAR(5)) AS test_round,
  CAST(goal AS VARCHAR(25)) AS goal,
  CAST(lvl_num AS INT) AS lvl_num
FROM
  gabby.lit.individualized_goals_archive AS g
