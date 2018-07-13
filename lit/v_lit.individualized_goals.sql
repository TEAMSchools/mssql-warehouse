USE gabby
GO

CREATE OR ALTER VIEW lit.individualized_goals AS

SELECT student_number
      ,academic_year
      ,test_round
      ,goal
      ,lvl_num
FROM gabby.lit.individualized_goals_current g
WHERE g.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT CONVERT(INT,student_number) AS student_number
      ,CONVERT(INT,academic_year) AS academic_year
      ,CONVERT(VARCHAR(5),test_round) AS test_round
      ,CONVERT(VARCHAR(25),goal) AS goal
      ,CONVERT(INT,lvl_num) AS lvl_num
FROM gabby.lit.individualized_goals_archive g