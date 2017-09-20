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
        ,ar1_mastery
        ,ar1_mastery_fiction
        ,ar1_mastery_nonfiction
        ,ar1_n_fiction
        ,ar1_n_nonfic
        ,ar1_n_passed
        ,ar1_n_total
        ,ar1_ontrack_words
        ,ar1_pct_fiction
        ,ar1_pct_goal
        ,ar1_pct_passing
        ,ar1_stu_status_words
        ,ar1_words
        ,ar1_words_goal
        ,ar2_mastery
        ,ar2_mastery_fiction
        ,ar2_mastery_nonfiction
        ,ar2_n_fiction
        ,ar2_n_nonfic
        ,ar2_n_passed
        ,ar2_n_total
        ,ar2_ontrack_words
        ,ar2_pct_fiction
        ,ar2_pct_goal
        ,ar2_pct_passing
        ,ar2_stu_status_words
        ,ar2_words
        ,ar2_words_goal
        ,ar3_mastery
        ,ar3_mastery_fiction
        ,ar3_mastery_nonfiction
        ,ar3_n_fiction
        ,ar3_n_nonfic
        ,ar3_n_passed
        ,ar3_n_total
        ,ar3_ontrack_words
        ,ar3_pct_fiction
        ,ar3_pct_goal
        ,ar3_pct_passing
        ,ar3_stu_status_words
        ,ar3_words
        ,ar3_words_goal
        ,ar4_mastery
        ,ar4_mastery_fiction
        ,ar4_mastery_nonfiction
        ,ar4_n_fiction
        ,ar4_n_nonfic
        ,ar4_n_passed
        ,ar4_n_total
        ,ar4_ontrack_words
        ,ar4_pct_fiction
        ,ar4_pct_goal
        ,ar4_pct_passing
        ,ar4_stu_status_words
        ,ar4_words
        ,ar4_words_goal
        ,ary_mastery
        ,ary_mastery_fiction
        ,ary_mastery_nonfiction
        ,ary_n_fiction
        ,ary_n_nonfic
        ,ary_n_passed
        ,ary_n_total
        ,ary_ontrack_words
        ,ary_pct_fiction
        ,ary_pct_goal
        ,ary_pct_passing
        ,ary_stu_status_words
        ,ary_words
        ,ary_words_goal
        ,cur_mastery
        ,cur_mastery_fiction
        ,cur_mastery_nonfiction
        ,cur_n_fiction
        ,cur_n_nonfic
        ,cur_n_passed
        ,cur_n_total
        ,cur_ontrack_words
        ,cur_pct_fiction
        ,cur_pct_goal
        ,cur_pct_passing
        ,cur_stu_status_words
        ,cur_words
        ,cur_words_goal
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
                  ,CONVERT(NVARCHAR,n_passed) AS n_passed
                  ,CONVERT(NVARCHAR,n_total) AS n_total
                  ,CONVERT(NVARCHAR,mastery) AS mastery
                  ,CONVERT(NVARCHAR,mastery_fiction) AS mastery_fiction
                  ,CONVERT(NVARCHAR,mastery_nonfiction) AS mastery_nonfiction
                  ,CONVERT(NVARCHAR,words) AS words
                  ,CONVERT(NVARCHAR,words_goal) AS words_goal
                  ,CONVERT(NVARCHAR,ontrack_words) AS ontrack_words
                  ,CONVERT(NVARCHAR,stu_status_words) AS stu_status_words
                  ,CONVERT(NVARCHAR,n_fiction) AS n_fiction
                  ,CONVERT(NVARCHAR,n_nonfic) AS n_nonfic
                  ,CONVERT(NVARCHAR,pct_fiction) AS pct_fiction           
                  ,CONVERT(NVARCHAR,ROUND((CONVERT(FLOAT,n_passed) / CONVERT(FLOAT,n_total) * 100),1)) AS pct_passing
                  ,CONVERT(NVARCHAR,CASE
                                     WHEN CONVERT(FLOAT,ROUND((words / words_goal * 100),1)) > 100 THEN 100 
                                     ELSE CONVERT(FLOAT,ROUND((words / words_goal * 100),1))
                                    END) AS pct_goal
            FROM gabby.renaissance.ar_progress_to_goals
            WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
              AND words_goal > 0

            UNION ALL

            SELECT student_number
                  ,academic_year
                  ,'CUR' reporting_term
                  ,CONVERT(NVARCHAR,n_passed) AS n_passed
                  ,CONVERT(NVARCHAR,n_total) AS n_total
                  ,CONVERT(NVARCHAR,mastery) AS mastery
                  ,CONVERT(NVARCHAR,mastery_fiction) AS mastery_fiction
                  ,CONVERT(NVARCHAR,mastery_nonfiction) AS mastery_nonfiction
                  ,CONVERT(NVARCHAR,words) AS words
                  ,CONVERT(NVARCHAR,words_goal) AS words_goal
                  ,CONVERT(NVARCHAR,ontrack_words) AS ontrack_words
                  ,CONVERT(NVARCHAR,stu_status_words) AS stu_status_words
                  ,CONVERT(NVARCHAR,n_fiction) AS n_fiction
                  ,CONVERT(NVARCHAR,n_nonfic) AS n_nonfic
                  ,CONVERT(NVARCHAR,pct_fiction) AS pct_fiction        
                  ,CONVERT(NVARCHAR,ROUND((CONVERT(FLOAT,n_passed) / CONVERT(FLOAT,n_total) * 100),1)) AS pct_passing
                  ,CONVERT(NVARCHAR,CASE
                                     WHEN CONVERT(FLOAT,ROUND((words / words_goal * 100),1)) > 100 THEN 100 
                                     ELSE CONVERT(FLOAT,ROUND((words / words_goal * 100),1))
                                    END) AS pct_goal
            FROM gabby.renaissance.ar_progress_to_goals
            WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
              AND words_goal > 0
              AND CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
           ) sub
       UNPIVOT(
         value
         FOR field IN (n_passed
                      ,n_total
                      ,mastery
                      ,mastery_fiction
                      ,mastery_nonfiction
                      ,words
                      ,words_goal
                      ,ontrack_words
                      ,stu_status_words
                      ,n_fiction
                      ,n_nonfic
                      ,pct_fiction
                      ,pct_passing
                      ,pct_goal)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN (ar1_mastery
                       ,ar1_mastery_fiction
                       ,ar1_mastery_nonfiction
                       ,ar1_n_fiction
                       ,ar1_n_nonfic
                       ,ar1_n_passed
                       ,ar1_n_total
                       ,ar1_ontrack_words
                       ,ar1_pct_fiction
                       ,ar1_pct_goal
                       ,ar1_pct_passing
                       ,ar1_stu_status_words
                       ,ar1_words
                       ,ar1_words_goal
                       ,ar2_mastery
                       ,ar2_mastery_fiction
                       ,ar2_mastery_nonfiction
                       ,ar2_n_fiction
                       ,ar2_n_nonfic
                       ,ar2_n_passed
                       ,ar2_n_total
                       ,ar2_ontrack_words
                       ,ar2_pct_fiction
                       ,ar2_pct_goal
                       ,ar2_pct_passing
                       ,ar2_stu_status_words
                       ,ar2_words
                       ,ar2_words_goal
                       ,ar3_mastery
                       ,ar3_mastery_fiction
                       ,ar3_mastery_nonfiction
                       ,ar3_n_fiction
                       ,ar3_n_nonfic
                       ,ar3_n_passed
                       ,ar3_n_total
                       ,ar3_ontrack_words
                       ,ar3_pct_fiction
                       ,ar3_pct_goal
                       ,ar3_pct_passing
                       ,ar3_stu_status_words
                       ,ar3_words
                       ,ar3_words_goal
                       ,ar4_mastery
                       ,ar4_mastery_fiction
                       ,ar4_mastery_nonfiction
                       ,ar4_n_fiction
                       ,ar4_n_nonfic
                       ,ar4_n_passed
                       ,ar4_n_total
                       ,ar4_ontrack_words
                       ,ar4_pct_fiction
                       ,ar4_pct_goal
                       ,ar4_pct_passing
                       ,ar4_stu_status_words
                       ,ar4_words
                       ,ar4_words_goal
                       ,ary_mastery
                       ,ary_mastery_fiction
                       ,ary_mastery_nonfiction
                       ,ary_n_fiction
                       ,ary_n_nonfic
                       ,ary_n_passed
                       ,ary_n_total
                       ,ary_ontrack_words
                       ,ary_pct_fiction
                       ,ary_pct_goal
                       ,ary_pct_passing
                       ,ary_stu_status_words
                       ,ary_words
                       ,ary_words_goal
                       ,cur_mastery
                       ,cur_mastery_fiction
                       ,cur_mastery_nonfiction
                       ,cur_n_fiction
                       ,cur_n_nonfic
                       ,cur_n_passed
                       ,cur_n_total
                       ,cur_ontrack_words
                       ,cur_pct_fiction
                       ,cur_pct_goal
                       ,cur_pct_passing
                       ,cur_stu_status_words
                       ,cur_words
                       ,cur_words_goal)
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
            FROM gabby.nwea.assessment_result_identifiers
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
            FROM gabby.nwea.best_baseline
            WHERE measurementscale = 'Reading'         
              AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 

            UNION ALL

            SELECT student_id
                  ,academic_year
                  ,'cur' AS term
                  ,CONVERT(FLOAT,test_ritscore)
                  ,CONVERT(FLOAT,percentile_2015_norms)
                  ,CONVERT(FLOAT,ritto_reading_score)
            FROM gabby.nwea.assessment_result_identifiers
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
      ,ar_wide.cur_n_passed AS n_passed
      ,ar_wide.cur_n_total AS n_total
      ,ar_wide.cur_mastery AS cur_accuracy
      ,ar_wide.cur_mastery_fiction AS cur_accuracy_fiction
      ,ar_wide.cur_mastery_nonfiction AS cur_accuracy_nonfiction      
      ,ar_wide.cur_words AS hex_words
      ,ar_wide.cur_words_goal AS hex_goal
      ,ar_wide.cur_stu_status_words AS hex_on_track     
      ,CASE
        WHEN CONVERT(INT,ar_wide.cur_ontrack_words) - CONVERT(INT,ar_wide.cur_words) < 0 THEN 0
        ELSE CONVERT(INT,ar_wide.cur_ontrack_words) - CONVERT(INT,ar_wide.cur_words)
       END AS hex_needed      
      --,ar_wide.cur_rank_words_grade_in_school AS term_rank_words
      ,NULL AS hex_rank_words

       /* AR yr */      
      ,ar_wide.ary_mastery AS accuracy
      ,ar_wide.ary_mastery_fiction AS accuracy_fiction
      ,ar_wide.ary_mastery_nonfiction AS accuracy_nonfiction
      ,ar_wide.ary_n_fiction AS n_fiction
      ,ar_wide.ary_n_nonfic AS n_nonfic
      ,100 - ar_wide.ary_pct_fiction AS year_pct_nf 
      --,ar_wide.ary_rank_words_grade_in_school AS year_rank_words      
      ,NULL AS year_rank_words
      ,ar_wide.ary_words AS year_words
      ,ar_wide.ary_words_goal AS year_goal
      ,ROUND((CONVERT(FLOAT,ar_wide.ary_n_passed) / CONVERT(FLOAT,ar_wide.ary_n_total) * 100), 1) AS pct_passing_yr
      
      /* AR by term */
      ,ar_wide.ar1_mastery AS hex1_accuracy_all
      ,ar_wide.ar1_mastery_fiction AS hex1_accuracy_fiction
      ,ar_wide.ar1_mastery_nonfiction AS hex1_accuracy_nonfiction
      ,ar_wide.ar1_words_goal AS hex1_goal
      ,ar_wide.ar1_pct_goal AS hex1_pct_goal
      ,ar_wide.ar1_pct_passing AS hex1_pct_passing
      ,ar_wide.ar1_words AS hex1_words
      ,ar_wide.ar2_mastery AS hex2_accuracy_all
      ,ar_wide.ar2_mastery_fiction AS hex2_accuracy_fiction
      ,ar_wide.ar2_mastery_nonfiction AS hex2_accuracy_nonfiction
      ,ar_wide.ar2_words_goal AS hex2_goal
      ,ar_wide.ar2_pct_goal AS hex2_pct_goal
      ,ar_wide.ar2_pct_passing AS hex2_pct_passing
      ,ar_wide.ar2_words AS hex2_words
      ,ar_wide.ar3_mastery AS hex3_accuracy_all
      ,ar_wide.ar3_mastery_fiction AS hex3_accuracy_fiction
      ,ar_wide.ar3_mastery_nonfiction AS hex3_accuracy_nonfiction
      ,ar_wide.ar3_words_goal AS hex3_goal
      ,ar_wide.ar3_pct_goal AS hex3_pct_goal
      ,ar_wide.ar3_pct_passing AS hex3_pct_passing
      ,ar_wide.ar3_words AS hex3_words
      ,ar_wide.ar4_mastery AS hex4_accuracy_all
      ,ar_wide.ar4_mastery_fiction AS hex4_accuracy_fiction
      ,ar_wide.ar4_mastery_nonfiction AS hex4_accuracy_nonfiction
      ,ar_wide.ar4_words_goal AS hex4_goal
      ,ar_wide.ar4_pct_goal AS hex4_pct_goal
      ,ar_wide.ar4_pct_passing AS hex4_pct_passing
      ,ar_wide.ar4_words AS hex4_words
      ,NULL AS hex5_accuracy_all
      ,NULL AS hex5_accuracy_fiction
      ,NULL AS hex5_accuracy_nonfiction
      ,NULL AS hex5_goal
      ,NULL AS hex5_pct_goal
      ,NULL AS hex5_pct_passing
      ,NULL AS hex5_words
      ,NULL AS hex6_accuracy_all
      ,NULL AS hex6_accuracy_fiction
      ,NULL AS hex6_accuracy_nonfiction
      ,NULL AS hex6_goal
      ,NULL AS hex6_pct_goal
      ,NULL AS hex6_pct_passing
      ,NULL AS hex6_words
      
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