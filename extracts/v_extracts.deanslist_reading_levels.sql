USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_reading_levels AS

SELECT student_number
      ,academic_year
      ,test_round
      ,CASE 
        WHEN reporting_term = 'LIT4' THEN read_lvl
        WHEN end_date > CONVERT(DATE,GETDATE()) THEN NULL
        WHEN end_date <= CONVERT(DATE,GETDATE()) THEN read_lvl        
        WHEN is_new_test = 1 THEN read_lvl
        ELSE prev_read_lvl
       END AS read_lvl
      ,goal_lvl
      ,CASE 
        WHEN reporting_term = 'LIT4' THEN lvl_num
        WHEN end_date > CONVERT(DATE,GETDATE()) THEN NULL
        WHEN end_date <= CONVERT(DATE,GETDATE()) THEN lvl_num
        WHEN is_new_test = 1 THEN lvl_num
        ELSE prev_lvl_num
       END AS read_lvl_num
      ,goal_num AS goal_lvl_num
      ,CASE
        WHEN reporting_term != 'LIT4' AND end_date > CONVERT(DATE,GETDATE()) THEN NULL
        WHEN met_goal = 1 THEN 'On Track'
        WHEN met_goal = 0 THEN 'Off Track'
       END AS met_goal
FROM gabby.lit.achieved_by_round_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()  