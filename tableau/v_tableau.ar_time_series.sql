USE gabby
GO

CREATE OR ALTER VIEW tableau.ar_time_series AS

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
      ,is_ontrack_term
      ,is_ontrack_yr
FROM gabby.tableau.ar_time_series_current_static

UNION ALL

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
      ,is_ontrack_term
      ,is_ontrack_yr
FROM gabby.tableau.ar_time_series_archive
WHERE academic_year = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)