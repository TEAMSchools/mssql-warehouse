USE KIPP_NJ
GO

ALTER VIEW DL$instructional_tech#extract AS 

/* AR */
SELECT student_number
      ,academic_year
      ,CASE
        WHEN time_period_name = 'Year' THEN 'Y1'
        ELSE REPLACE(time_period_name, 'RT','Q')
       END AS term
      ,'Accelerated Reader' AS it_program
      ,words AS progress
      ,words_goal AS goal
      ,stu_status_words AS goal_status
FROM KIPP_NJ..AR$progress_to_goals_long#static WITH(NOLOCK)
WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

UNION ALL

/* ST Math */
SELECT student_number
      ,academic_year
      ,term      
      ,'ST Math' AS it_program
      ,ROUND(SUM(progress),0) AS progress
      ,ROUND((MAX(days_elapsed) / MAX(total_days)) * 100,0) AS goal
      ,CASE
        WHEN CONVERT(DATE,GETDATE()) >= MAX(end_date) AND ROUND(SUM(progress),0) >= ROUND((MAX(days_elapsed) / MAX(total_days)) * 100,0) THEN 'Met Goal'
        WHEN CONVERT(DATE,GETDATE()) >= MAX(end_date) AND ROUND(SUM(progress),0) < ROUND((MAX(days_elapsed) / MAX(total_days)) * 100,0) THEN 'Missed Goal'
        WHEN ROUND(SUM(progress),0) >= ROUND((MAX(days_elapsed) / MAX(total_days)) * 100,0) THEN 'On Track'        
        WHEN ROUND(SUM(progress),0) < ROUND((MAX(days_elapsed) / MAX(total_days)) * 100,0) THEN 'Off Track'
       END AS goal_status
FROM
    (
     SELECT stm.school_student_id AS student_number
           ,stm.start_year AS academic_year      
           ,stm.K_5_Progress AS progress      
           ,dt.time_per_name AS term
           ,dt.start_date
           ,dt.end_date
           ,CONVERT(FLOAT,DATEDIFF(DAY, dt.start_date, CASE WHEN CONVERT(DATE,GETDATE()) > dt.end_date THEN dt.end_date ELSE CONVERT(DATE,GETDATE()) END)) AS days_elapsed
           ,CONVERT(FLOAT,DATEDIFF(DAY, dt.start_date, dt.end_date)) AS total_days
           ,ROW_NUMBER() OVER(
              PARTITION BY stm.school_student_id, stm.start_year, stm.GCD
                ORDER BY stm.week_ending_date DESC) AS rn_gcd
     FROM KIPP_NJ..STMATH$progress_completion_long stm WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
       ON stm.start_year = dt.academic_year
      AND dt.identifier = 'SY'
     WHERE stm.school_student_id IS NOT NULL
       AND stm.start_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
WHERE rn_gcd = 1
GROUP BY student_number
        ,academic_year
        ,term

UNION ALL

/* Lexia */
SELECT student_number
      ,academic_year
      ,term
      ,it_program
      ,progress
      ,goal
      ,CASE
        WHEN CONVERT(DATE,GETDATE()) >= end_date AND progress >= goal THEN 'Met Goal'
        WHEN CONVERT(DATE,GETDATE()) >= end_date AND progress < goal THEN 'Missed Goal'
        WHEN progress >= goal THEN 'On Track'        
        WHEN progress < goal THEN 'Off Track'
       END AS goal_status
FROM
    (
     SELECT lex.student_number
           ,lex.year AS academic_year
           ,dt.time_per_name AS term
           ,dt.start_date
           ,dt.end_date
           ,'Lexia' AS it_program
           ,ROUND(lex.pct_to_target * 100,0) AS progress
           ,ROUND((CONVERT(FLOAT,DATEDIFF(DAY, dt.start_date, CASE WHEN CONVERT(DATE,GETDATE()) > dt.end_date THEN dt.end_date ELSE CONVERT(DATE,GETDATE()) END)) 
                     / CONVERT(FLOAT,DATEDIFF(DAY, dt.start_date, dt.end_date))) * 100,0) AS goal
     FROM KIPP_NJ..TABLEAU$lexia_tracker lex WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
       ON lex.year = dt.academic_year
      AND dt.identifier = 'SY'
     WHERE lex.rn_curr = 1
       AND lex.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub