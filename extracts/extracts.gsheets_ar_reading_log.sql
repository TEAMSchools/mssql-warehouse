USE gabby
GO

ALTER VIEW extracts.gsheets_ar_reading_log AS

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
    AND start_date <= CONVERT(DATE,GETDATE())
)

,ar_wide AS (
  SELECT student_number
        ,academic_year
        ,[ar1_accuracy_all]
        ,[ar1_accuracy_fiction]
        ,[ar1_accuracy_nonfiction]
        ,[ar1_goal]
        ,[ar1_pct_goal]
        ,[ar1_pct_passing]
        ,[ar1_words]
        ,[ar2_accuracy_all]
        ,[ar2_accuracy_fiction]
        ,[ar2_accuracy_nonfiction]
        ,[ar2_goal]
        ,[ar2_pct_goal]
        ,[ar2_pct_passing]
        ,[ar2_words]
        ,[ar3_accuracy_all]
        ,[ar3_accuracy_fiction]
        ,[ar3_accuracy_nonfiction]
        ,[ar3_goal]
        ,[ar3_pct_goal]
        ,[ar3_pct_passing]
        ,[ar3_words]
        ,[ar4_accuracy_all]
        ,[ar4_accuracy_fiction]
        ,[ar4_accuracy_nonfiction]
        ,[ar4_goal]
        ,[ar4_pct_goal]
        ,[ar4_pct_passing]
        ,[ar4_words]
        ,[ar5_accuracy_all]
        ,[ar5_accuracy_fiction]
        ,[ar5_accuracy_nonfiction]
        ,[ar5_goal]
        ,[ar5_pct_goal]
        ,[ar5_pct_passing]
        ,[ar5_words]
        ,[ar6_accuracy_all]
        ,[ar6_accuracy_fiction]
        ,[ar6_accuracy_nonfiction]
        ,[ar6_goal]
        ,[ar6_pct_goal]
        ,[ar6_pct_passing]
        ,[ar6_words]
  FROM
      (
       SELECT student_number
             ,academic_year
             ,CONCAT(reporting_term, '_', field) AS pivot_field
             ,value
       FROM
           (
            SELECT student_number
                  ,academic_year
                  ,reporting_term
                  ,CONVERT(NVARCHAR,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, words),1),'.00','')) AS words
                  ,CONVERT(NVARCHAR,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, words_goal),1),'.00','')) AS goal
                  ,CONVERT(NVARCHAR,mastery_fiction) AS accuracy_fiction
                  ,CONVERT(NVARCHAR,mastery_nonfiction) AS accuracy_nonfiction
                  ,CONVERT(NVARCHAR,mastery) AS accuracy_all           
                  ,CONVERT(NVARCHAR,ROUND((CONVERT(FLOAT,n_passed) / CONVERT(FLOAT,n_total) * 100),1)) AS pct_passing
                  ,CONVERT(NVARCHAR,CASE
                    WHEN CONVERT(FLOAT,ROUND((words / words_goal * 100),1)) > 100 THEN 100 
                    ELSE CONVERT(FLOAT,ROUND((words / words_goal * 100),1))
                   END) AS pct_goal
            FROM gabby.renaissance.ar_progress_to_goals_static
            WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
              AND reporting_term != 'ARY'
              AND words_goal > 0
           ) sub
       UNPIVOT(
         value
         FOR field IN (words
                      ,goal
                      ,pct_goal
                      ,pct_passing
                      ,accuracy_fiction
                      ,accuracy_nonfiction
                      ,accuracy_all)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([ar1_accuracy_all]
                       ,[ar1_accuracy_fiction]
                       ,[ar1_accuracy_nonfiction]
                       ,[ar1_goal]
                       ,[ar1_pct_goal]
                       ,[ar1_pct_passing]
                       ,[ar1_words]
                       ,[ar2_accuracy_all]
                       ,[ar2_accuracy_fiction]
                       ,[ar2_accuracy_nonfiction]
                       ,[ar2_goal]
                       ,[ar2_pct_goal]
                       ,[ar2_pct_passing]
                       ,[ar2_words]
                       ,[ar3_accuracy_all]
                       ,[ar3_accuracy_fiction]
                       ,[ar3_accuracy_nonfiction]
                       ,[ar3_goal]
                       ,[ar3_pct_goal]
                       ,[ar3_pct_passing]
                       ,[ar3_words]
                       ,[ar4_accuracy_all]
                       ,[ar4_accuracy_fiction]
                       ,[ar4_accuracy_nonfiction]
                       ,[ar4_goal]
                       ,[ar4_pct_goal]
                       ,[ar4_pct_passing]
                       ,[ar4_words]
                       ,[ar5_accuracy_all]
                       ,[ar5_accuracy_fiction]
                       ,[ar5_accuracy_nonfiction]
                       ,[ar5_goal]
                       ,[ar5_pct_goal]
                       ,[ar5_pct_passing]
                       ,[ar5_words]
                       ,[ar6_accuracy_all]
                       ,[ar6_accuracy_fiction]
                       ,[ar6_accuracy_nonfiction]
                       ,[ar6_goal]
                       ,[ar6_pct_goal]
                       ,[ar6_pct_passing]
                       ,[ar6_words])
   ) p
)

,map_wide AS (
  SELECT student_id AS student_number
        ,academic_year
        ,[base_rit_score]
        ,[base_percentile_score]
        ,[base_lexile_score]
        ,[fall_rit_score]
        ,[fall_percentile_score]
        ,[fall_lexile_score]
        ,[winter_rit_score]
        ,[winter_percentile_score]
        ,[winter_lexile_score]
        ,[spring_rit_score]
        ,[spring_percentile_score]
        ,[spring_lexile_score]      
        ,[cur_rit_score]
        ,[cur_percentile_score]
        ,[cur_lexile_score]      
  FROM
      (
       SELECT student_id
             ,academic_year
             ,CONCAT(term, '_', field) AS pivot_field
             ,value
       FROM
           (
            SELECT student_id
                  ,academic_year
                  ,LOWER(term) AS term
                  ,CONVERT(FLOAT,test_ritscore) AS rit_score
                  ,CONVERT(FLOAT,percentile_2015_norms) AS percentile_score
                  ,CONVERT(FLOAT,ritto_reading_score) AS lexile_score
            FROM gabby.nwea.assessment_result_identifiers_static   
            WHERE measurement_scale = 'Reading'  
              AND rn_term_subj = 1
              AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

            UNION ALL

            SELECT student_number
                  ,academic_year
                  ,'base' AS term
                  ,CONVERT(FLOAT,test_ritscore)
                  ,CONVERT(FLOAT,testpercentile)
                  ,CONVERT(FLOAT,lexile_score)
            FROM gabby.nwea.best_baseline_static
            WHERE measurementscale = 'Reading'         
              AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 

            UNION ALL

            SELECT student_id
                  ,academic_year
                  ,'cur' AS term
                  ,CONVERT(FLOAT,test_ritscore)
                  ,CONVERT(FLOAT,percentile_2015_norms)
                  ,CONVERT(FLOAT,ritto_reading_score)
            FROM gabby.nwea.assessment_result_identifiers_static
            WHERE measurement_scale = 'Reading'  
              AND rn_curr_yr = 1
              AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
           ) sub
       UNPIVOT(
         value
         FOR field IN (rit_score, percentile_score, lexile_score)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([winter_rit_score]
                       ,[winter_percentile_score]
                       ,[winter_lexile_score]
                       ,[spring_rit_score]
                       ,[spring_percentile_score]
                       ,[spring_lexile_score]
                       ,[fall_rit_score]
                       ,[fall_percentile_score]
                       ,[fall_lexile_score]
                       ,[cur_rit_score]
                       ,[cur_percentile_score]
                       ,[cur_lexile_score]
                       ,[base_rit_score]
                       ,[base_percentile_score]
                       ,[base_lexile_score])
   ) p
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.school_name AS school     
      ,co.grade_level
      ,co.team
      ,CONCAT(co.first_name, ' ', co.last_name) AS name
      
      /* AR curterm */            
      ,ar_cur.n_passed
      ,ar_cur.n_total      
      ,ar_cur.mastery AS cur_accuracy
      ,ar_cur.mastery_fiction AS cur_accuracy_fiction
      ,ar_cur.mastery_nonfiction AS cur_accuracy_nonfiction      
      ,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, ar_cur.words),1),'.00','') AS hex_words
      ,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, ar_cur.words_goal),1),'.00','') AS hex_goal
      ,CASE
        WHEN ar_cur.ontrack_words - ar_cur.words < 0 THEN '0'
        ELSE REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, ar_cur.ontrack_words - ar_cur.words),1),'.00','')
       END AS hex_needed
      ,ar_cur.stu_status_words AS hex_on_track     
      --,ar_cur.rank_words_grade_in_school AS term_rank_words
      ,NULL AS hex_rank_words

       /* AR yr */      
      ,ar_year.mastery AS accuracy
      ,ar_year.mastery_fiction AS accuracy_fiction
      ,ar_year.mastery_nonfiction AS accuracy_nonfiction
      ,ar_year.n_fiction
      ,ar_year.n_nonfic
      ,100 - ar_year.pct_fiction AS year_pct_nf 
      --,ar_year.rank_words_grade_in_school AS year_rank_words      
      ,NULL AS year_rank_words      
      ,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY,ar_year.words),1),'.00','') AS year_words
      ,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY,ar_year.words_goal),1),'.00','') AS year_goal
      ,ROUND((CONVERT(FLOAT,ar_year.n_passed) / CONVERT(FLOAT,ar_year.n_total) * 100), 1) AS pct_passing_yr
      
      /* AR by term */
      ,ar_wide.ar1_accuracy_all AS hex1_accuracy_all
      ,ar_wide.ar1_accuracy_fiction AS hex1_accuracy_fiction
      ,ar_wide.ar1_accuracy_nonfiction AS hex1_accuracy_nonfiction
      ,ar_wide.ar1_goal AS hex1_goal
      ,ar_wide.ar1_pct_goal AS hex1_pct_goal
      ,ar_wide.ar1_pct_passing AS hex1_pct_passing
      ,ar_wide.ar1_words AS hex1_words
      ,ar_wide.ar2_accuracy_all AS hex2_accuracy_all
      ,ar_wide.ar2_accuracy_fiction AS hex2_accuracy_fiction
      ,ar_wide.ar2_accuracy_nonfiction AS hex2_accuracy_nonfiction
      ,ar_wide.ar2_goal AS hex2_goal
      ,ar_wide.ar2_pct_goal AS hex2_pct_goal
      ,ar_wide.ar2_pct_passing AS hex2_pct_passing
      ,ar_wide.ar2_words AS hex2_words
      ,ar_wide.ar3_accuracy_all AS hex3_accuracy_all
      ,ar_wide.ar3_accuracy_fiction AS hex3_accuracy_fiction
      ,ar_wide.ar3_accuracy_nonfiction AS hex3_accuracy_nonfiction
      ,ar_wide.ar3_goal AS hex3_goal
      ,ar_wide.ar3_pct_goal AS hex3_pct_goal
      ,ar_wide.ar3_pct_passing AS hex3_pct_passing
      ,ar_wide.ar3_words AS hex3_words
      ,ar_wide.ar4_accuracy_all AS hex4_accuracy_all
      ,ar_wide.ar4_accuracy_fiction AS hex4_accuracy_fiction
      ,ar_wide.ar4_accuracy_nonfiction AS hex4_accuracy_nonfiction
      ,ar_wide.ar4_goal AS hex4_goal
      ,ar_wide.ar4_pct_goal AS hex4_pct_goal
      ,ar_wide.ar4_pct_passing AS hex4_pct_passing
      ,ar_wide.ar4_words AS hex4_words
      ,ar_wide.ar5_accuracy_all AS hex5_accuracy_all
      ,ar_wide.ar5_accuracy_fiction AS hex5_accuracy_fiction
      ,ar_wide.ar5_accuracy_nonfiction AS hex5_accuracy_nonfiction
      ,ar_wide.ar5_goal AS hex5_goal
      ,ar_wide.ar5_pct_goal AS hex5_pct_goal
      ,ar_wide.ar5_pct_passing AS hex5_pct_passing
      ,ar_wide.ar5_words AS hex5_words
      ,ar_wide.ar6_accuracy_all AS hex6_accuracy_all
      ,ar_wide.ar6_accuracy_fiction AS hex6_accuracy_fiction
      ,ar_wide.ar6_accuracy_nonfiction AS hex6_accuracy_nonfiction
      ,ar_wide.ar6_goal AS hex6_goal
      ,ar_wide.ar6_pct_goal AS hex6_pct_goal
      ,ar_wide.ar6_pct_passing AS hex6_pct_passing
      ,ar_wide.ar6_words  AS hex6_words 
      
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
      
      ,ele.h_cur AS cur_term_rdg_hw_avg
      ,ele.h_y1 AS y1_rdg_hw_avg 

      /* MAP */
      ,map_wide.base_rit_score AS map_baseline
      ,map_wide.base_lexile_score AS lexile_baseline_map                 
      ,map_wide.fall_lexile_score AS lexile_fall      
      ,map_wide.winter_lexile_score AS lexile_winter       
      ,COALESCE(map_wide.cur_rit_score, map_wide.base_rit_score) AS cur_rit
      ,COALESCE(map_wide.cur_percentile_score, map_wide.base_percentile_score) AS cur_rit_percentile      
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN gabby.reporting.reporting_terms curhex
  ON co.schoolid = curhex.schoolid  
 AND CONVERT(DATE,GETDATE()) BETWEEN CONVERT(DATE,curhex.start_date) AND CONVERT(DATE,curhex.end_date)
 AND curhex.identifier = 'AR'
 AND curhex.time_per_name != 'ARY'
LEFT OUTER JOIN gabby.renaissance.ar_progress_to_goals_static ar_cur 
  ON co.student_number = ar_cur.student_number
 AND co.academic_year = ar_cur.academic_year
 AND curhex.time_per_name = ar_cur.reporting_term
LEFT OUTER JOIN gabby.renaissance.ar_progress_to_goals_static  ar_year
  ON co.student_number = ar_year.student_number
 AND co.academic_year = ar_year.academic_year
 AND ar_year.reporting_term = 'ARY' 
LEFT OUTER JOIN ar_wide 
  ON co.student_number = ar_wide.student_number
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
 AND CONVERT(DATE,GETDATE()) BETWEEN enr.dateenrolled AND enr.dateleft
LEFT OUTER JOIN gabby.powerschool.final_grades_static gr
  ON co.student_number = gr.student_number
 AND enr.course_number = gr.course_number
 AND gr.is_curterm = 1
LEFT OUTER JOIN gabby.powerschool.category_grades_wide ele
  ON co.student_number = ele.student_number
 AND co.academic_year = ele.academic_year 
 AND gr.course_number = ele.course_number   
 AND ele.is_curterm = 1
LEFT OUTER JOIN map_wide
  ON co.student_number = map_wide.student_number
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()  
  AND co.school_level = 'MS'
  AND co.enroll_status = 0    
  AND co.rn_year = 1