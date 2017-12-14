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
    AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND start_date <= GETDATE()
)

SELECT co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.school_name AS school     
      ,co.grade_level
      ,co.team
      
      /* AR curterm */            
      
      ,ar_cur.mastery AS cur_accuracy      
      ,ar_cur.words AS hex_words
      ,ar_cur.words_goal AS hex_goal
      ,ar_cur.stu_status_words AS hex_on_track     
      ,CASE
        WHEN CONVERT(INT,ar_cur.ontrack_words) - CONVERT(INT,ar_cur.words) < 0 THEN 0
        ELSE CONVERT(INT,ar_cur.ontrack_words) - CONVERT(INT,ar_cur.words)
       END AS hex_needed

       /* AR yr */      
      ,ar_y1.mastery_fiction AS accuracy_fiction
      ,ar_y1.mastery_nonfiction AS accuracy_nonfiction            
      ,ar_y1.words AS year_words
      ,ar_y1.words_goal AS year_goal
      ,100 - ar_y1.pct_fiction AS year_pct_nf 
      
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
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN fp fp_base
  ON co.student_number = fp_base.student_number
 AND fp_base.rn_base = 1
LEFT OUTER JOIN fp fp_curr
  ON co.student_number = fp_curr.student_number
 AND fp_curr.rn_curr = 1
LEFT OUTER JOIN gabby.powerschool.course_enrollments_static enr
  ON co.studentid = enr.studentid
 AND co.academic_year = enr.academic_year
 AND enr.credittype = 'ENG'
 AND GETDATE() BETWEEN enr.dateenrolled AND enr.dateleft
LEFT OUTER JOIN gabby.powerschool.final_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year
 AND enr.course_number = gr.course_number
 AND gr.is_curterm = 1
LEFT OUTER JOIN gabby.powerschool.category_grades_static ele
  ON co.student_number = ele.student_number
 AND co.academic_year = ele.academic_year 
 AND gr.course_number = ele.course_number   
 AND ele.grade_category = 'H'
 AND ele.is_curterm = 1
LEFT OUTER JOIN gabby.renaissance.ar_progress_to_goals ar_cur
  ON co.student_number = ar_cur.student_number
 AND GETDATE() BETWEEN ar_cur.start_date AND ar_cur.end_date
 AND ar_cur.reporting_term != 'ARY'
 AND ar_cur.words_goal > 0           
LEFT OUTER JOIN gabby.renaissance.ar_progress_to_goals ar_y1
  ON co.student_number = ar_y1.student_number
 AND co.academic_year = ar_y1.academic_year
 AND ar_y1.reporting_term = 'ARY'
 AND ar_y1.words_goal > 0           
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()  
  AND co.school_level = 'MS'
  AND co.enroll_status = 0    
  AND co.rn_year = 1