USE gabby
GO

CREATE OR ALTER VIEW renaissance.ar_individualized_goals_long AS

SELECT student_number
      ,CONVERT(NVARCHAR(4), REPLACE(reporting_term, 'q_', 'AR')) AS reporting_term
      ,CONVERT(INT, adjusted_goal) AS adjusted_goal
FROM
    (
     SELECT student_number
           ,q_1
           ,q_2
           ,q_3
           ,q_4
           ,ROW_NUMBER() OVER(PARTITION BY student_number ORDER BY _row DESC) AS rn
     FROM gabby.renaissance.ar_individualized_goals
     WHERE _fivetran_deleted = 0
    ) sub
UNPIVOT(
  adjusted_goal
  FOR reporting_term IN (q_1, q_2, q_3, q_4)
 ) u
WHERE rn = 1
