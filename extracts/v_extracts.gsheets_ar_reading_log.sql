USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_ar_reading_log AS

WITH fp AS (
  SELECT student_number
        ,read_lvl
        ,fp_wpmrate
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY start_date ASC) AS rn_base
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY start_date DESC) AS rn_curr
  FROM gabby.lit.achieved_by_round_static
  WHERE read_lvl IS NOT NULL    
    AND start_date BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND GETDATE()
 )

,ar_wide AS (
  SELECT student_number
        ,[cur_words]
        ,[cur_words_goal]
        ,[cur_stu_status_words]
        ,[cur_mastery]
        ,[cur_mastery_fiction]
        ,[cur_pct_nonfiction]
        ,[cur_words_needed]
        ,[cur_mastery_nonfiction]
        ,[y1_words]
        ,[y1_words_goal]
        ,[y1_stu_status_words]
        ,[y1_mastery]
        ,[y1_mastery_fiction]
        ,[y1_pct_nonfiction]
        ,[y1_words_needed]
        ,[y1_mastery_nonfiction]
  FROM
      (
       SELECT student_number      
             ,CONCAT(reporting_term, '_', field) AS pivot_field
             ,value
       FROM
           (
            SELECT student_number
                  ,CASE
                    WHEN reporting_term = 'ARY' THEN 'y1'
                    ELSE 'cur'
                   END AS reporting_term

                  ,CONVERT(VARCHAR,words) AS words
                  ,CONVERT(VARCHAR,words_goal) AS words_goal
                  ,CONVERT(VARCHAR,stu_status_words) AS stu_status_words
                  ,CONVERT(VARCHAR,mastery) AS mastery
                  ,CONVERT(VARCHAR,mastery_fiction) AS mastery_fiction
                  ,CONVERT(VARCHAR,mastery_nonfiction) AS mastery_nonfiction
                  ,CONVERT(VARCHAR,100 - pct_fiction) AS pct_nonfiction            
                  ,CONVERT(VARCHAR,CASE
                    WHEN CONVERT(INT,ontrack_words) - CONVERT(INT,words) < 0 THEN 0
                    ELSE CONVERT(INT,ontrack_words) - CONVERT(INT,words)
                   END) AS words_needed
            FROM gabby.renaissance.ar_progress_to_goals
            WHERE words_goal > 0
              AND (CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date)
           ) sub
       UNPIVOT (
         value
         FOR field IN (words
                      ,words_goal
                      ,stu_status_words
                      ,mastery
                      ,mastery_fiction
                      ,mastery_nonfiction
                      ,pct_nonfiction
                      ,words_needed)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([cur_words]
                       ,[cur_words_goal]
                       ,[cur_stu_status_words]
                       ,[cur_mastery]
                       ,[cur_mastery_fiction]
                       ,[cur_pct_nonfiction]
                       ,[cur_words_needed]
                       ,[cur_mastery_nonfiction]
                       ,[y1_words]
                       ,[y1_words_goal]
                       ,[y1_stu_status_words]
                       ,[y1_mastery]
                       ,[y1_mastery_fiction]
                       ,[y1_pct_nonfiction]
                       ,[y1_words_needed]
                       ,[y1_mastery_nonfiction])
   ) p
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.school_name AS school     
      ,co.grade_level
      ,co.team
      
      ,ar_wide.cur_mastery AS cur_accuracy      
      ,ar_wide.cur_words AS hex_words
      ,ar_wide.cur_words_goal AS hex_goal
      ,ar_wide.cur_stu_status_words AS hex_on_track     
      ,ar_wide.cur_words_needed AS hex_needed
      ,ar_wide.y1_mastery_fiction AS accuracy_fiction
      ,ar_wide.y1_mastery_nonfiction AS accuracy_nonfiction
      ,ar_wide.y1_words AS year_words
      ,ar_wide.y1_words_goal AS year_goal
      ,ar_wide.y1_pct_nonfiction AS year_pct_nf

      /* F&P */
      ,fp_base.read_lvl AS fp_base_letter
      ,fp_base.fp_wpmrate AS starting_fluency

      ,fp_curr.read_lvl AS fp_cur_letter      
      ,fp_curr.fp_wpmrate AS cur_fluency     
      
      /* course enrollments */      
      ,enr.course_number
      ,enr.course_name
      ,enr.course_name + ' | ' + enr.section_number AS enr_hash

      /* gradebook grades */
      ,gr.term_grade_percent AS cur_term_rdg_gr
      ,gr.y1_grade_percent_adjusted AS y1_rdg_gr
      
      ,ele.grade_category_pct AS cur_term_rdg_hw_avg            

      ,bk.vch_content_title AS last_book_title
      ,CONVERT(VARCHAR,bk.dt_taken) AS last_book_quiz_date
      ,bk.d_percent_correct * 100 AS last_book_quiz_pct_correct
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.course_enrollments_static enr
  ON co.studentid = enr.studentid 
 AND co.db_name = enr.db_name
 AND enr.credittype = 'ENG'
 AND CONVERT(DATE,GETDATE()) BETWEEN enr.dateenrolled AND enr.dateleft
 AND enr.rn_subject = 1
LEFT JOIN gabby.powerschool.final_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year
 AND co.db_name = gr.db_name
 AND enr.course_number = gr.course_number
 AND gr.is_curterm = 1
LEFT JOIN gabby.powerschool.category_grades_static ele
  ON co.student_number = ele.student_number
 AND co.academic_year = ele.academic_year 
 AND co.db_name = ele.db_name
 AND enr.course_number = ele.course_number   
 AND ele.grade_category = 'H'
 AND ele.is_curterm = 1
LEFT JOIN fp fp_base
  ON co.student_number = fp_base.student_number
 AND fp_base.rn_base = 1
LEFT JOIN fp fp_curr
  ON co.student_number = fp_curr.student_number
 AND fp_curr.rn_curr = 1
LEFT JOIN ar_wide
  ON co.student_number = ar_wide.student_number
LEFT JOIN gabby.renaissance.ar_most_recent_quiz_static bk
  ON co.student_number = bk.student_number
 AND co.academic_year = bk.academic_year
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()  
  AND co.school_level = 'MS'
  AND co.enroll_status = 0    
  AND co.rn_year = 1