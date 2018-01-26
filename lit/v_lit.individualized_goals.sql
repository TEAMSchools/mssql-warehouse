USE gabby
GO

CREATE OR ALTER VIEW lit.individualized_goals AS

WITH gdoc_long AS (
  SELECT student_number
        ,academic_year        
        ,UPPER(LEFT(field, CHARINDEX('_', field) - 1)) AS test_round
        ,CONVERT(VARCHAR(25),goal) AS goal
  FROM 
      (
       SELECT CONVERT(INT,SUBSTRING(name, (CHARINDEX('[', name) + 1), (CHARINDEX(']', name)) - (CHARINDEX('[', name) + 1))) AS student_number
             ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
             ,SUBSTRING([diagnostic_goal], CHARINDEX(' ',[diagnostic_goal]) + 1, LEN([diagnostic_goal])) AS diagnostic_goal
             ,SUBSTRING([q_1_goal], CHARINDEX(' ',[q_1_goal]) + 1, LEN([q_1_goal])) AS q1_goal
             ,SUBSTRING([q_2_goal], CHARINDEX(' ',[q_2_goal]) + 1, LEN([q_2_goal])) AS q2_goal
             ,SUBSTRING([q_3_goal], CHARINDEX(' ',[q_3_goal]) + 1, LEN([q_3_goal])) AS q3_goal
             ,SUBSTRING([q_4_goal], CHARINDEX(' ',[q_4_goal]) + 1, LEN([q_4_goal])) AS q4_goal
       FROM gabby.lit.individualized_goal_entry       
       WHERE _fivetran_deleted IS NULL
      ) sub
  UNPIVOT (
    goal
    FOR field IN ([diagnostic_goal]
                 ,[q1_goal]
                 ,[q2_goal]
                 ,[q3_goal]
                 ,[q4_goal])
   ) u
 )

SELECT g.student_number
      ,g.academic_year
      ,CONVERT(VARCHAR(5),REPLACE(g.test_round,'DIAGNOSTIC','DR')) AS test_round
      ,g.goal      
      ,CONVERT(INT,CASE 
        WHEN gleq.testid = 3273 THEN gleq.fp_lvl_num /* when F&P, use F&P number */
        ELSE gleq.lvl_num
       END) AS lvl_num
FROM gdoc_long g
LEFT OUTER JOIN gabby.lit.gleq
  ON g.goal = gleq.read_lvl

UNION ALL

SELECT CONVERT(INT,student_number) AS student_number
      ,CONVERT(INT,academic_year) AS academic_year
      ,CONVERT(VARCHAR(5),test_round) AS test_round
      ,CONVERT(VARCHAR(25),goal) AS goal
      ,CONVERT(INT,lvl_num) AS lvl_num
FROM gabby.lit.individualized_goals_archive g