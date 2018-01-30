USE gabby
GO

CREATE OR ALTER VIEW tableau.ar_time_series AS

WITH ar_long AS (
  SELECT student_number
        ,academic_year              
        ,CONVERT(DATE,dt_taken) AS date_taken        
        ,MIN(CONVERT(DATE,dt_taken)) OVER(PARTITION BY student_number, academic_year) AS min_date_taken        
        ,SUM(CASE WHEN rn_quiz = 1 THEN ti_passed END) AS n_books_passed
        ,COUNT(CASE WHEN rn_quiz = 1 THEN i_student_practice_id END) AS n_books_read
        ,SUM(CASE WHEN ti_passed = 1 AND rn_quiz = 1 THEN d_points_earned END) AS n_points_earned
        ,SUM(CASE WHEN ti_passed = 1 AND rn_quiz = 1 THEN i_word_count END) AS n_words_read        
        ,SUM(CASE WHEN ch_fiction_non_fiction = 'F' AND rn_quiz = 1 THEN 1 ELSE 0 END) AS n_fiction        
        ,SUM(CASE WHEN rn_quiz = 1 THEN d_percent_correct END) AS total_pct_correct
        ,SUM(CASE WHEN rn_quiz = 1 THEN fl_lexile_calc END) AS total_lexile
  FROM gabby.renaissance.ar_studentpractice_identifiers
  GROUP BY student_number
          ,academic_year      
          ,CONVERT(DATE,dt_taken)
 )

,last_book AS (
  SELECT student_number
        ,academic_year
        ,DATEDIFF(DAY, dt_taken, GETDATE()) AS n_days_ago
        ,CASE 
          WHEN rn_quiz > 1 THEN 'RETAKE - ' + vch_content_title
          ELSE vch_content_title 
         END AS book_title
        ,i_lexile AS book_lexile
        ,d_percent_correct AS book_pct_correct
        ,i_word_count AS word_count
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY dt_taken DESC) AS rn
  FROM gabby.renaissance.ar_studentpractice_identifiers
  WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
 )

SELECT student_number
      ,lastfirst
      ,academic_year
      ,schoolid
      ,grade_level
      ,team
      ,advisor_name
      ,iep_status
      ,term
      ,date      
      ,course_name
      ,course_number
      ,section_number
      ,teacher_name
      ,homeroom_section
      ,homeroom_teacher
      ,words_goal_yr
      ,points_goal_yr
      ,goal_term
      ,words_goal_term
      ,points_goal_term
      ,n_words_read
      ,n_points_earned
      ,n_books_read
      ,n_fiction
      ,total_lexile
      ,total_pct_correct
      ,last_book_title
      ,last_book_days_ago
      ,last_book_lexile
      ,last_book_pct_correct
      ,ontrack_words_yr           
      ,ontrack_words_term
      ,is_current_week
      ,is_curterm           
      ,n_words_read_running_term
      ,n_words_read_running_yr
      ,CASE 
        WHEN ontrack_words_term IS NULL THEN NULL
        WHEN schoolid != 73253 AND n_words_read_running_term >= ontrack_words_term THEN 1
        ELSE 0
       END AS is_ontrack_term
      ,CASE 
        WHEN ontrack_words_yr IS NULL THEN NULL
        WHEN schoolid != 73253 AND n_words_read_running_yr >= ontrack_words_yr THEN 1
        ELSE 0
       END AS is_ontrack_yr
FROM
    (
     SELECT student_number
           ,lastfirst
           ,academic_year
           ,schoolid
           ,grade_level
           ,team
           ,advisor_name
           ,iep_status
           ,term
           ,date      
           ,course_name
           ,course_number
           ,section_number
           ,teacher_name
           ,homeroom_section
           ,homeroom_teacher
           ,words_goal_yr
           ,points_goal_yr
           ,goal_term
           ,words_goal_term
           ,points_goal_term
           ,n_words_read
           ,n_points_earned
           ,n_books_read
           ,n_fiction
           ,total_lexile
           ,total_pct_correct
           ,last_book_title
           ,last_book_days_ago
           ,last_book_lexile
           ,last_book_pct_correct

           ,words_goal_yr * (CONVERT(FLOAT,DATEDIFF(DAY, y1_start_date, date)) / DATEDIFF(DAY, y1_start_date, y1_end_date)) AS ontrack_words_yr           
           ,words_goal_term * (CONVERT(FLOAT,DATEDIFF(DAY, term_start_date, date)) / DATEDIFF(DAY, term_start_date, term_end_date)) AS ontrack_words_term           
           
           ,CASE 
             WHEN DATEPART(WEEK,date) = DATEPART(WEEK,CONVERT(DATE,GETDATE())) THEN 1 
             WHEN DATEPART(WEEK,date) = DATEPART(WEEK,MAX(date) OVER(PARTITION BY schoolid, academic_year, student_number)) THEN 1 
             ELSE 0 
            END AS is_current_week
           ,CASE 
             WHEN CONVERT(DATE,GETDATE()) BETWEEN term_start_date AND term_end_date THEN 1 
             WHEN MAX(date) OVER(PARTITION BY schoolid, academic_year, student_number) BETWEEN term_start_date AND term_end_date THEN 1 
             ELSE 0 
            END AS is_curterm           
           ,SUM(n_words_read) OVER(
              PARTITION BY student_number, academic_year, term
                ORDER BY date) AS n_words_read_running_term
           ,SUM(n_words_read) OVER(
              PARTITION BY student_number, academic_year
                ORDER BY date) AS n_words_read_running_yr
     FROM
         (
          SELECT co.student_number
                ,co.lastfirst
                ,co.academic_year
                ,co.reporting_schoolid AS schoolid
                ,co.grade_level
                ,co.team
                ,co.advisor_name
                ,co.iep_status           
                ,co.date                      

                ,CONVERT(VARCHAR(25),dts.alt_name) AS term
                ,CONVERT(VARCHAR(25),dts.time_per_name) AS goal_term
                ,dts.start_date AS term_start_date
                ,dts.end_date AS term_end_date

                ,y1dts.start_date AS y1_start_date
                ,y1dts.end_date AS y1_end_date
           
                ,enr.course_name
                ,enr.course_number
                ,enr.section_number
                ,enr.teacher_name           
           
                ,hr.section_number AS homeroom_section
                ,hr.teacher_name AS homeroom_teacher

                ,y1_goal.words_goal AS words_goal_yr
                ,y1_goal.points_goal AS points_goal_yr
           
                ,term_goal.words_goal AS words_goal_term
                ,term_goal.points_goal AS points_goal_term           
      
                ,ar.n_words_read
                ,ar.n_points_earned
                ,ar.n_books_read
                ,ar.n_fiction
                ,ar.total_lexile
                ,ar.total_pct_correct
           
                ,bk.book_title AS last_book_title
                ,bk.n_days_ago AS last_book_days_ago 
                ,bk.book_lexile AS last_book_lexile
                ,bk.book_pct_correct AS last_book_pct_correct
                ,bk.word_count AS last_book_word_count
          FROM gabby.powerschool.cohort_identifiers_scaffold co
          LEFT OUTER JOIN gabby.reporting.reporting_terms dts
            ON co.schoolid = dts.schoolid
           AND co.date BETWEEN dts.start_date AND dts.end_date
           AND dts.identifier = 'AR'
           AND dts.time_per_name != 'ARY'
          LEFT OUTER JOIN gabby.reporting.reporting_terms y1dts
            ON co.academic_year = y1dts.academic_year
           AND co.schoolid = y1dts.schoolid      
           AND y1dts.identifier = 'AR'
           AND y1dts.time_per_name = 'ARY'
          LEFT OUTER JOIN gabby.powerschool.course_enrollments_static enr 
            ON co.student_number = enr.student_number
           AND co.academic_year = enr.academic_year
           AND enr.credittype = 'ENG'
           AND enr.section_enroll_status = 0
           AND enr.rn_subject = 1
          LEFT OUTER JOIN gabby.powerschool.course_enrollments_static hr
            ON co.student_number = hr.student_number
           AND co.academic_year = hr.academic_year
           AND hr.course_number = 'HR'
           AND hr.section_enroll_status = 0      
           AND hr.rn_subject = 1
          LEFT OUTER JOIN gabby.renaissance.ar_goals y1_goal
            ON co.student_number = y1_goal.student_number
           AND co.academic_year = y1_goal.academic_year
           AND y1_goal.reporting_term = 'ARY'
          LEFT OUTER JOIN gabby.renaissance.ar_goals term_goal
            ON co.student_number = term_goal.student_number   
           AND co.academic_year = term_goal.academic_year
           AND dts.time_per_name = term_goal.reporting_term      
          LEFT OUTER JOIN ar_long ar
            ON co.student_number = ar.student_number
           AND co.date = ar.date_taken
          LEFT OUTER JOIN last_book bk
            ON co.student_number = bk.student_number
           AND co.academic_year = bk.academic_year
           AND bk.rn = 1
          WHERE co.reporting_schoolid NOT IN (999999, 5173)
            AND co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
            AND co.date <= CONVERT(DATE,GETDATE())
            AND co.enroll_status = 0       
            AND ((co.grade_level BETWEEN 5 AND 8)
                   OR (co.schoolid IN (179901) AND co.grade_level >= 3)
                   OR (co.schoolid IN (73255) AND co.grade_level >= 2))       
         ) sub
    ) sub