USE gabby
GO

--ALTER VIEW REPORTING$reading_log AS

WITH curhex AS (
  SELECT schoolid
        ,time_per_name AS reporting_term
        ,alt_name
        ,CONVERT(DATE,start_date) AS start_date
        ,CONVERT(DATE,end_date) AS end_date
  FROM gabby.reporting.reporting_terms
  WHERE CONVERT(DATE,GETDATE()) BETWEEN CONVERT(DATE,start_date) AND CONVERT(DATE,end_date)
    AND identifier = 'AR'
 )

,fp AS (
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
                  ,CONVERT(NVARCHAR,ROUND((CONVERT(FLOAT,N_passed) / CONVERT(FLOAT,N_total) * 100),1)) AS pct_passing
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

SELECT co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.school_name AS school     
      ,co.grade_level
      ,co.team
      ,CONCAT(co.first_name, ' ', co.last_name) AS name
      
      ,enr.course_name + '|' + enr.section_number AS enr_hash
      ,enr.course_number
      ,enr.course_name

      /* grades */
      ,gr.term_grade_percent AS cur_term_rdg_gr
      ,gr.y1_grade_percent_adjusted AS y1_rdg_gr
      
      ,ele.H_CUR AS cur_term_rdg_hw_avg
      ,ele.H_Y1 AS y1_rdg_hw_avg
      
      /* F&P */
      ,fp_base.read_lvl AS fp_base_letter
      ,fp_base.fp_wpmrate AS starting_fluency

      ,fp_curr.read_lvl AS fp_cur_letter      
      ,fp_curr.fp_wpmrate AS cur_fluency      

      /* MAP */
      ,base.test_ritscore AS map_baseline
      ,base.lexile_score AS lexile_baseline_MAP      
      
      ,map_fall.ritto_reading_score AS lexile_fall
      
      ,map_winter.ritto_reading_score AS lexile_winter       

      ,COALESCE(cur_rit.test_ritscore, base.test_ritscore) AS cur_RIT
      ,COALESCE(cur_rit.percentile_2015_norms, base.testpercentile) AS cur_RIT_percentile             
 
       /* AR curterm */      
      ,ar_cur.stu_status_words AS term_on_track     
      ,ar_cur.N_passed
      ,ar_cur.N_total      
      ,ar_cur.mastery AS cur_accuracy
      ,ar_cur.mastery_fiction AS cur_accuracy_fiction
      ,ar_cur.mastery_nonfiction AS cur_accuracy_nonfiction
      --,ar_cur.rank_words_grade_in_school AS term_rank_words
      ,NULL AS term_rank_words
      ,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, ar_cur.words),1),'.00','') AS term_words
      ,REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, ar_cur.words_goal),1),'.00','') AS term_goal
      ,CASE
        WHEN ar_cur.ontrack_words - ar_cur.words < 0 THEN '0'
        ELSE REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY, ar_cur.ontrack_words - ar_cur.words),1),'.00','')
       END AS term_needed

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
      ,ROUND((CONVERT(FLOAT,ar_year.N_passed) / CONVERT(FLOAT,ar_year.N_total) * 100), 1) AS pct_passing_yr
      
      /* AR by term */
      ,ar_wide.ar1_accuracy_all
      ,ar_wide.ar1_accuracy_fiction
      ,ar_wide.ar1_accuracy_nonfiction
      ,ar_wide.ar1_goal
      ,ar_wide.ar1_pct_goal
      ,ar_wide.ar1_pct_passing
      ,ar_wide.ar1_words
      ,ar_wide.ar2_accuracy_all
      ,ar_wide.ar2_accuracy_fiction
      ,ar_wide.ar2_accuracy_nonfiction
      ,ar_wide.ar2_goal
      ,ar_wide.ar2_pct_goal
      ,ar_wide.ar2_pct_passing
      ,ar_wide.ar2_words
      ,ar_wide.ar3_accuracy_all
      ,ar_wide.ar3_accuracy_fiction
      ,ar_wide.ar3_accuracy_nonfiction
      ,ar_wide.ar3_goal
      ,ar_wide.ar3_pct_goal
      ,ar_wide.ar3_pct_passing
      ,ar_wide.ar3_words
      ,ar_wide.ar4_accuracy_all
      ,ar_wide.ar4_accuracy_fiction
      ,ar_wide.ar4_accuracy_nonfiction
      ,ar_wide.ar4_goal
      ,ar_wide.ar4_pct_goal
      ,ar_wide.ar4_pct_passing
      ,ar_wide.ar4_words
      ,ar_wide.ar5_accuracy_all
      ,ar_wide.ar5_accuracy_fiction
      ,ar_wide.ar5_accuracy_nonfiction
      ,ar_wide.ar5_goal
      ,ar_wide.ar5_pct_goal
      ,ar_wide.ar5_pct_passing
      ,ar_wide.ar5_words
      ,ar_wide.ar6_accuracy_all
      ,ar_wide.ar6_accuracy_fiction
      ,ar_wide.ar6_accuracy_nonfiction
      ,ar_wide.ar6_goal
      ,ar_wide.ar6_pct_goal
      ,ar_wide.ar6_pct_passing
      ,ar_wide.ar6_words        
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN curhex
  ON co.schoolid = curhex.schoolid  
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
LEFT OUTER JOIN fp fp_base
  ON co.student_number = fp_base.student_number
 AND fp_base.rn_base = 1
LEFT OUTER JOIN fp fp_curr
  ON co.student_number = fp_curr.student_number
 AND fp_curr.rn_curr = 1
LEFT OUTER JOIN gabby.renaissance.ar_progress_to_goals_static ar_cur 
  ON co.student_number = ar_cur.student_number
 AND co.academic_year = ar_cur.academic_year
 AND curhex.reporting_term = ar_cur.reporting_term
LEFT OUTER JOIN gabby.renaissance.ar_progress_to_goals_static  ar_year
  ON co.student_number = ar_year.student_number
 AND co.academic_year = ar_year.academic_year
 AND ar_year.reporting_term = 'ARY' 
LEFT OUTER JOIN ar_wide 
  ON co.student_number = ar_wide.student_number
LEFT OUTER JOIN gabby.nwea.best_baseline_static base
  ON co.student_number = base.student_number
 AND co.academic_year = base.academic_year
 AND base.measurementscale = 'Reading'
LEFT OUTER JOIN gabby.nwea.assessment_result_identifiers_static map_fall
  ON co.student_number = map_fall.student_id
 AND co.academic_year = map_fall.academic_year
 AND map_fall.measurement_scale = 'Reading' 
 AND map_fall.term = 'Fall'
 AND map_fall.rn_term_subj = 1
LEFT OUTER JOIN gabby.nwea.assessment_result_identifiers_static map_winter
  ON co.studentid = map_winter.student_id
 AND co.academic_year = map_winter.academic_year
 AND map_winter.measurement_scale = 'Reading' 
 AND map_winter.term = 'Winter'
 AND map_winter.rn_term_subj = 1
LEFT OUTER JOIN gabby.nwea.assessment_result_identifiers_static map_spr 
  ON co.studentid = map_spr.student_id
 AND co.academic_year - 1 = map_spr.academic_year
 AND map_spr.measurement_scale = 'Reading' 
 AND map_spr.term = 'Spring'
 AND map_spr.rn_term_subj = 1
LEFT OUTER JOIN gabby.nwea.assessment_result_identifiers_static cur_rit
  ON co.studentid = cur_rit.student_id 
 AND co.academic_year = cur_rit.academic_year
 AND cur_rit.measurement_scale = 'Reading'    
 AND cur_rit.rn_curr_yr = 1
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.reporting_schoolid IN (73252, 133570965, 73258, 73255, 179902, 179903, 1799015075)
  AND co.enroll_status = 0    
  AND co.rn_year = 1    