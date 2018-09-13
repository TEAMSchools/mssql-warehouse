USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_reading_levels AS

SELECT student_number
      ,academic_year
      ,test_round
      ,read_lvl
      ,goal_lvl
      ,lvl_num AS read_lvl_num
      ,goal_num AS goal_lvl_num
      ,goal_status AS met_goal
FROM gabby.lit.achieved_by_round_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()  