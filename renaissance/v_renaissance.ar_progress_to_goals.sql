USE gabby
GO

ALTER VIEW renaissance.ar_progress_to_goals AS

WITH progress_rollup AS (
  SELECT co.student_number        
        ,co.academic_year        
        
        ,rt.time_per_name AS reporting_term
        ,CONVERT(DATE,rt.start_date) AS start_date
        ,CONVERT(DATE,rt.end_date) AS end_date
        ,CONVERT(FLOAT,DATEDIFF(DAY, CONVERT(DATE,rt.start_date), CONVERT(DATE,GETDATE()))) AS n_days_elapsed
        ,CONVERT(FLOAT,DATEDIFF(DAY, CONVERT(DATE,rt.start_date), CONVERT(DATE,rt.end_date))) AS n_days_term

        ,SUM(CASE WHEN arsp.ti_passed = 1 AND arsp.rn_quiz = 1 THEN arsp.i_word_count ELSE 0 END) AS words
        ,NULL AS points
        --,SUM(CASE WHEN arsp.ti_passed = 1 AND arsp.rn_quiz = 1 THEN arsp.d_points_earned ELSE 0 END) AS points            
            
        ,ROUND(
           (SUM(CASE WHEN arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_questions_correct) END) 
              / SUM(CASE WHEN arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_questions_presented) END)) 
              * 100, 0) AS mastery            
        ,ROUND(
           (SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_questions_correct) END) 
              / SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_questions_presented) END))
              * 100, 0) AS mastery_fiction
        ,ROUND(
           (SUM(CASE WHEN arsp.ch_fiction_non_fiction != 'F' AND arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_questions_correct) END)
              / SUM(CASE WHEN arsp.ch_fiction_non_fiction != 'F' AND arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_questions_presented) END)) 
              * 100, 0) AS mastery_nonfiction            
            
        ,SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN 1 END) AS n_fiction
        ,SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'NF' AND arsp.rn_quiz = 1 THEN 1 END) AS n_nonfic            
        ,ROUND(
           (SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_word_count) ELSE 0 END) 
              / SUM(CASE WHEN arsp.rn_quiz = 1 THEN CONVERT(FLOAT,arsp.i_word_count) END))
              * 100, 0) AS pct_fiction
            
        ,ROUND(AVG(CASE WHEN arsp.rn_quiz = 1 THEN fl_lexile_calc END), 0) AS avg_lexile
        ,ROUND(AVG(CASE WHEN arsp.rn_quiz = 1 THEN arsp.ti_book_rating END), 2) AS avg_rating
        ,MAX(arsp.dt_taken) AS last_quiz_date
        ,SUM(CASE WHEN arsp.rn_quiz = 1 THEN arsp.ti_passed END) AS n_passed
        ,COUNT(CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_user_id END) AS n_total                                 
  FROM gabby.powerschool.cohort_identifiers_static co
  JOIN gabby.reporting.reporting_terms rt
    ON co.academic_year = rt.academic_year       
   AND co.schoolid = rt.schoolid
   AND rt.identifier = 'AR'     
  LEFT OUTER JOIN gabby.renaissance.ar_studentpractice_identifiers arsp
    ON co.student_number = arsp.student_number
   AND CONVERT(DATE,arsp.dt_taken) BETWEEN CONVERT(DATE,rt.start_date) AND CONVERT(DATE,rt.end_date)
  WHERE co.rn_year = 1    
    AND co.schoolid != 999999    
  GROUP BY co.student_number             
          ,co.academic_year              
          ,rt.time_per_name
          ,CONVERT(DATE,rt.start_date)
          ,CONVERT(DATE,rt.end_date)          
 )
 
SELECT pr.student_number      
      ,pr.academic_year      
      ,pr.reporting_term
      ,pr.start_date
      ,pr.end_date      
      ,pr.words
      ,pr.points
      ,pr.mastery
      ,pr.mastery_fiction
      ,pr.mastery_nonfiction
      ,pr.pct_fiction
      ,pr.n_fiction
      ,pr.n_nonfic
      ,pr.avg_lexile
      ,pr.avg_rating
      ,pr.last_quiz_date
      ,pr.n_passed
      ,pr.n_total      

      ,goals.words_goal      

      ,CASE                
        /* any time */
        WHEN (words IS NULL OR goals.words_goal IS NULL) THEN NULL        
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN goals.words_goal
        /* during term */
        ELSE ROUND((pr.n_days_elapsed / pr.n_days_term) * goals.words_goal, 0) 
       END AS ontrack_words
      ,CASE        
        /* any time */
        WHEN (words IS NULL OR goals.words_goal IS NULL) THEN NULL
        WHEN words >= goals.words_goal THEN 'Met Goal'                
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date AND words < goals.words_goal  THEN 'Missed Goal'
        WHEN words >= ROUND((pr.n_days_elapsed / pr.n_days_term) * goals.words_goal, 0) THEN 'On Track'
        /* during term */
        WHEN words < ROUND((pr.n_days_elapsed / pr.n_days_term) * goals.words_goal, 0) THEN 'Off Track'        
       END AS stu_status_words
      ,CASE
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) NOT BETWEEN start_date AND end_date THEN NULL
        /* during term */
        ELSE CASE
              WHEN (words IS NULL OR goals.words_goal IS NULL) THEN NULL
              WHEN words >= ROUND((pr.n_days_elapsed / pr.n_days_term) * goals.words_goal, 0) THEN NULL
              ELSE ROUND((pr.n_days_elapsed / pr.n_days_term) * goals.words_goal, 0) - words
             END
       END AS words_needed    
         
      /* UNUSED */
      ,NULL AS points_goal
      ,NULL AS ontrack_points
      ,NULL AS stu_status_points
      ,NULL AS stu_status_words_numeric
      ,NULL AS stu_status_points_numeric
      ,NULL AS points_needed      
      /*
      ,goals.points_goal      
      ,CASE        
        /* any time */
        WHEN (points IS NULL OR points_goal IS NULL) THEN NULL        
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN points_goal 
        /* during term */
        ELSE ROUND((pr.n_days_elapsed / pr.n_days_term) * points_goal,0) /* during time period */
       END AS ontrack_points            
      ,CASE        
        /* any time */
        WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
        WHEN points >= points_goal THEN 'Met Goal'                
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date AND points < points_goal  THEN 'Missed Goal'
        WHEN points >= ROUND((pr.n_days_elapsed / pr.n_days_term) * points_goal, 0) THEN 'On Track'
        /* during term */
        WHEN points < ROUND((pr.n_days_elapsed / pr.n_days_term) * points_goal, 0) THEN 'Off Track'        
       END AS stu_status_points            
      ,CASE        
        /* any time */
        WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
        WHEN words >= words_goal THEN 1
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date AND words < words_goal  THEN 0
        WHEN words >= ROUND((pr.n_days_elapsed / pr.n_days_term) * words_goal, 0) THEN 1
        /* during term */
        WHEN words < ROUND((pr.n_days_elapsed / pr.n_days_term) * words_goal, 0) THEN 0
       END AS stu_status_words_numeric      
      ,CASE        
        /* any time */
        WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
        WHEN points >= points_goal THEN 1
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date AND points < points_goal  THEN 0
        WHEN points >= ROUND((pr.n_days_elapsed / pr.n_days_term) * points_goal, 0) THEN 1
        /* during term */
        WHEN points < ROUND((pr.n_days_elapsed / pr.n_days_term) * points_goal, 0) THEN 0
       END AS stu_status_points_numeric   
      ,CASE
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) NOT BETWEEN start_date AND end_date THEN NULL
        /* during term */
        ELSE CASE
              WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
              WHEN points >= ROUND((pr.n_days_elapsed / pr.n_days_term) * points_goal, 0) THEN NULL
              ELSE ROUND((pr.n_days_elapsed / pr.n_days_term) * points_goal, 0) - points
             END
       END AS points_needed
      --*/      

      /* RANKS */
      /*
      ,RANK() OVER(PARTITION BY schoolid,grade_level,yearid,time_hierarchy,time_period_name ORDER BY words DESC) AS rank_words_grade_in_school
      ,RANK() OVER(PARTITION BY grade_level,yearid,time_hierarchy,time_period_name ORDER BY words DESC) AS rank_words_grade_in_network
      ,RANK() OVER(PARTITION BY schoolid,yearid,time_hierarchy,time_period_name ORDER BY words DESC) AS rank_words_overall_in_school
      ,RANK() OVER(PARTITION BY yearid,time_hierarchy,time_period_name ORDER BY words DESC) AS rank_words_overall_in_network       
      ,RANK() OVER(PARTITION BY schoolid,grade_level,yearid,time_hierarchy,time_period_name ORDER BY points DESC) AS rank_points_grade_in_school
      ,RANK() OVER(PARTITION BY grade_level,yearid,time_hierarchy,time_period_name ORDER BY points DESC) AS rank_points_grade_in_network
      ,RANK() OVER(PARTITION BY schoolid,yearid,time_hierarchy,time_period_name ORDER BY points DESC) AS rank_points_overall_in_school
      ,RANK() OVER(PARTITION BY yearid,time_hierarchy,time_period_name ORDER BY points DESC) AS rank_points_overall_in_network      
      */
FROM progress_rollup pr
LEFT OUTER JOIN gabby.renaissance.ar_goals goals
  ON pr.student_number = goals.student_number   
 AND pr.academic_year = goals.academic_year
 AND pr.reporting_term = goals.reporting_term  