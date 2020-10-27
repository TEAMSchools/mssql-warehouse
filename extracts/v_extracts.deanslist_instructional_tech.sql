USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_instructional_tech AS 

/* AR */
SELECT student_number
      ,academic_year
      ,CASE
        WHEN reporting_term = 'ARY' THEN 'Y1'
        ELSE REPLACE(reporting_term, 'AR','Q')
       END AS term
      ,'Accelerated Reader' AS it_program
      ,words AS progress
      ,words_goal AS goal
      ,stu_status_words AS goal_status
FROM gabby.renaissance.ar_progress_to_goals
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

--UNION ALL

--/* ST Math */
--SELECT school_student_id AS student_number
--      ,start_year AS academic_year
--      ,reporting_term AS term      
--      ,'ST Math' AS it_program
--      ,ROUND(SUM(k_5_progress), 0) AS progress
--      ,ROUND((MAX(days_elapsed) / MAX(total_days)) * 100, 0) AS goal
--      ,CASE
--        WHEN CONVERT(DATE,GETDATE()) >= MAX(term_end_date) AND ROUND(SUM(k_5_progress), 0) >= ROUND((MAX(days_elapsed) / MAX(total_days)) * 100, 0) THEN 'Met Goal'
--        WHEN CONVERT(DATE,GETDATE()) >= MAX(term_end_date) AND ROUND(SUM(k_5_progress), 0) < ROUND((MAX(days_elapsed) / MAX(total_days)) * 100, 0) THEN 'Missed Goal'
--        WHEN ROUND(SUM(k_5_progress), 0) >= ROUND((MAX(days_elapsed) / MAX(total_days)) * 100, 0) THEN 'On Track'        
--        WHEN ROUND(SUM(k_5_progress), 0) < ROUND((MAX(days_elapsed) / MAX(total_days)) * 100, 0) THEN 'Off Track'
--       END AS goal_status
--FROM gabby.stmath.progress_completion_report_clean
--WHERE start_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
--  AND rn_gcd = 1
--GROUP BY school_student_id
--        ,start_year
--        ,reporting_term 

--UNION ALL

--/* Lexia */
--SELECT student_number
--      ,academic_year
--      ,term
--      ,it_program
--      ,progress
--      ,goal
--      ,CASE
--        WHEN CONVERT(DATE,GETDATE()) >= end_date AND progress >= goal THEN 'Met Goal'
--        WHEN CONVERT(DATE,GETDATE()) >= end_date AND progress < goal THEN 'Missed Goal'
--        WHEN progress >= goal THEN 'On Track'        
--        WHEN progress < goal THEN 'Off Track'
--       END AS goal_status
--FROM
--    (
--     SELECT lex.student_number
--           ,lex.academic_year

--           ,dt.time_per_name AS term
--           ,CONVERT(DATE,dt.start_date) AS start_date
--           ,CONVERT(DATE,dt.end_date) AS end_date
           
--           ,'Lexia' AS it_program
           
--           ,ROUND(lex.pct_to_target * 100, 0) AS progress
--           ,ROUND((CONVERT(FLOAT,DATEDIFF(DAY, CONVERT(DATE,dt.start_date), CASE 
--                                                                             WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,dt.end_date) THEN CONVERT(DATE,dt.end_date) 
--                                                                             ELSE CONVERT(DATE,GETDATE()) 
--                                                                            END)) 
--                     / CONVERT(FLOAT,DATEDIFF(DAY, dt.start_date, dt.end_date))) * 100,0) AS goal
--     FROM gabby.tableau.lexia_tracker lex
--     JOIN gabby.reporting.reporting_terms dt 
--       ON lex.academic_year = dt.academic_year
--      AND dt.identifier = 'SY'
--      AND dt._fivetran_deleted = 0
--     WHERE lex.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
--       AND lex.rn_curr = 1
--    ) sub