USE gabby
GO

CREATE OR ALTER VIEW stmath.progress_completion_report_clean AS

SELECT iid
      ,institution_name
      ,tcd
      ,teacher_name
      ,scd
      ,student_name
      ,ycd
      ,start_year
      ,gcd
      ,num_lab_logins
      ,num_homework_logins
      ,k_5_progress
      ,k_5_mastery
      ,objective_name
      ,curr_obj_path
      ,uuid
      ,state_id
      ,alt_src_time
      ,CONVERT(DATE,first_login_date) AS first_login_date						
      ,CONVERT(DATE,last_login_date) AS last_login_date						

      ,CASE WHEN ISNUMERIC(school_student_id) = 1 THEN school_student_id ELSE NULL END AS school_student_id
      ,CASE WHEN ISNUMERIC(curr_hurdle_num_tries) = 1 THEN curr_hurdle_num_tries ELSE NULL END AS curr_hurdle_num_tries            
      ,CASE WHEN ISNUMERIC(fluency_progress) = 1 THEN fluency_progress ELSE NULL END AS fluency_progress
      ,CASE WHEN ISNUMERIC(fluency_mastery) = 1 THEN fluency_mastery ELSE NULL END AS fluency_mastery      
      ,CASE WHEN ISNUMERIC(fluency_time_spent) = 1 THEN fluency_time_spent ELSE NULL END AS fluency_time_spent      
      ,CASE WHEN ISNUMERIC(minutes_logged_last_week) = 1 THEN minutes_logged_last_week ELSE NULL END AS minutes_logged_last_week						
      ,CASE WHEN fluency_path = '\N' THEN NULL ELSE fluency_path END AS fluency_path      
      ,CONVERT(DATE,REPLACE(RIGHT(_file, 14),'.csv','')) AS week_end_date

      ,dt.time_per_name AS reporting_term
      ,CONVERT(DATE,dt.start_date) AS term_start_date
      ,CONVERT(DATE,dt.end_date) AS term_end_date      
      ,CONVERT(FLOAT,DATEDIFF(DAY, CONVERT(DATE,dt.start_date), CASE 
                                                                 WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,dt.end_date) THEN CONVERT(DATE,dt.end_date)
                                                                 ELSE CONVERT(DATE,GETDATE()) 
                                                                END)) AS days_elapsed
      ,CONVERT(FLOAT,DATEDIFF(DAY, CONVERT(DATE,dt.start_date), CONVERT(DATE,dt.end_date))) AS total_days
      
      ,ROW_NUMBER() OVER(
         PARTITION BY stm.school_student_id, stm.start_year, stm.GCD
           ORDER BY CONVERT(DATE,REPLACE(RIGHT(_file, 14),'.csv','')) DESC) AS rn_gcd
FROM gabby.stmath.progress_completion_report stm
JOIN gabby.reporting.reporting_terms dt
  ON stm.start_year = dt.academic_year
 AND dt.identifier = 'SY'
 AND dt.schoolid = 0