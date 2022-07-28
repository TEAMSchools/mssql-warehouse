USE gabby
GO

CREATE OR ALTER VIEW tableau.ar_time_series_current AS

SELECT student_number
      ,lastfirst
      ,academic_year
      ,region
      ,schoolid
      ,grade_level
      ,team
      ,advisor_name
      ,iep_status
      ,term
      ,[date]
      ,course_name
      ,course_number
      ,section_number
      ,teacher_name
      ,homeroom_section
      ,homeroom_teacher
      ,words_goal_yr
      ,NULL AS points_goal_yr
      ,goal_term
      ,words_goal_term
      ,NULL AS points_goal_term
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
        WHEN n_words_read_running_term >= ontrack_words_term THEN 1
        ELSE 0
       END AS is_ontrack_term
      ,CASE 
        WHEN ontrack_words_yr IS NULL THEN NULL
        WHEN n_words_read_running_yr >= ontrack_words_yr THEN 1
        ELSE 0
       END AS is_ontrack_yr
FROM
    (
     SELECT student_number
           ,lastfirst
           ,academic_year
           ,region
           ,schoolid
           ,grade_level
           ,team
           ,advisor_name
           ,iep_status
           ,term
           ,[date]
           ,course_name
           ,course_number
           ,section_number
           ,teacher_name
           ,homeroom_section
           ,homeroom_teacher
           ,words_goal_yr
           ,goal_term
           ,is_curterm
           ,words_goal_term
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

           ,words_goal_yr * (CONVERT(FLOAT, DATEDIFF(DAY, y1_start_date, [date])) / DATEDIFF(DAY, y1_start_date, y1_end_date)) AS ontrack_words_yr
           ,words_goal_term * (CONVERT(FLOAT, DATEDIFF(DAY, term_start_date, [date])) / DATEDIFF(DAY, term_start_date, term_end_date)) AS ontrack_words_term

           ,CASE
             WHEN DATEPART(WEEK, [date]) = DATEPART(WEEK, CONVERT(DATE, GETDATE())) THEN 1
             WHEN DATEPART(WEEK, [date]) = DATEPART(WEEK, MAX([date]) OVER(PARTITION BY schoolid, academic_year, student_number)) THEN 1
             ELSE 0
            END AS is_current_week
           ,SUM(n_words_read) OVER(
              PARTITION BY student_number, academic_year, term
                ORDER BY [date]) AS n_words_read_running_term
           ,SUM(n_words_read) OVER(
              PARTITION BY student_number, academic_year
                ORDER BY [date]) AS n_words_read_running_yr
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
                ,co.[date]
                ,co.region

                ,CONVERT(VARCHAR(25), dts.alt_name) AS term
                ,CONVERT(VARCHAR(25), dts.time_per_name) AS goal_term
                ,dts.[start_date] AS term_start_date
                ,dts.end_date AS term_end_date
                ,dts.is_curterm

                ,y1dts.[start_date] AS y1_start_date
                ,y1dts.end_date AS y1_end_date

                ,enr.course_name
                ,enr.course_number
                ,enr.section_number
                ,enr.teacher_name

                ,hr.section_number AS homeroom_section
                ,hr.teacher_name AS homeroom_teacher

                ,CASE WHEN y1_goal.words_goal > 0 THEN y1_goal.words_goal END AS words_goal_yr

                ,CASE WHEN term_goal.words_goal > 0 THEN term_goal.words_goal END AS words_goal_term

                ,ar.n_words_read
                ,ar.n_points_earned
                ,ar.n_books_read
                ,ar.n_fiction
                ,ar.total_lexile
                ,ar.total_pct_correct

                ,bk.n_days_ago AS last_book_days_ago
                ,bk.i_lexile AS last_book_lexile
                ,bk.d_percent_correct AS last_book_pct_correct
                ,bk.i_word_count AS last_book_word_count
                ,CASE WHEN bk.rn_quiz > 1 THEN 'RETAKE - ' + bk.vch_content_title ELSE bk.vch_content_title END AS last_book_title
          FROM gabby.powerschool.cohort_identifiers_scaffold_current_static co
          LEFT JOIN gabby.reporting.reporting_terms dts
            ON co.schoolid = dts.schoolid
           AND co.[date] BETWEEN dts.[start_date] AND dts.end_date
           AND dts.identifier = 'AR'
           AND dts.time_per_name <> 'ARY'
           AND dts._fivetran_deleted = 0
          LEFT JOIN gabby.reporting.reporting_terms y1dts
            ON co.academic_year = y1dts.academic_year
           AND co.schoolid = y1dts.schoolid      
           AND y1dts.identifier = 'AR'
           AND y1dts.time_per_name = 'ARY'
           AND y1dts._fivetran_deleted = 0
          LEFT JOIN gabby.powerschool.course_enrollments_current_static enr 
            ON co.student_number = enr.student_number
           AND co.academic_year = enr.academic_year
           AND co.[db_name] = enr.[db_name]
           AND enr.credittype = 'ENG'
           AND enr.course_enroll_status = 0
           AND enr.section_enroll_status = 0
           AND enr.rn_subject = 1
          LEFT JOIN gabby.powerschool.course_enrollments_current_static hr
            ON co.student_number = hr.student_number
           AND co.academic_year = hr.academic_year
           AND co.schoolid = hr.schoolid
           AND co.[db_name] = hr.[db_name]
           AND hr.course_number = 'HR'
           AND hr.course_enroll_status = 0
           AND hr.section_enroll_status = 0
           AND hr.rn_course_yr = 1
          LEFT JOIN gabby.renaissance.ar_goals_current_static y1_goal
            ON co.student_number = y1_goal.student_number
           AND co.academic_year = y1_goal.academic_year
           AND y1_goal.reporting_term = 'ARY'
          LEFT JOIN gabby.renaissance.ar_goals_current_static term_goal
            ON co.student_number = term_goal.student_number   
           AND co.academic_year = term_goal.academic_year
           AND dts.time_per_name = term_goal.reporting_term      
          LEFT JOIN gabby.renaissance.ar_most_recent_quiz_static bk
            ON co.student_number = bk.student_number
           AND co.academic_year = bk.academic_year
          LEFT JOIN gabby.renaissance.ar_studentpractice_rollup_static ar
            ON co.student_number = ar.student_number
           AND co.[date] = ar.date_taken
          WHERE co.enroll_status = 0
            AND (co.school_level = 'MS' OR (co.schoolid = 73256 AND co.grade_level = 4)) /* ad-hoc exception for Seek 4*/
            AND co.[date] <= CONVERT(DATE, GETDATE())
         ) sub
    ) sub
