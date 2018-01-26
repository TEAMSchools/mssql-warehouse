USE gabby
GO

CREATE OR ALTER VIEW renaissance.ar_progress_to_goals AS

WITH progress_rollup AS (
  SELECT co.student_number        
        ,co.academic_year        
        
        ,CONVERT(VARCHAR(5),rt.time_per_name) AS reporting_term
        ,rt.start_date
        ,rt.end_date
        ,CONVERT(FLOAT,DATEDIFF(DAY, rt.start_date, GETDATE())) AS n_days_elapsed
        ,CONVERT(FLOAT,DATEDIFF(DAY, rt.start_date, rt.end_date)) AS n_days_term

        ,SUM(CASE WHEN arsp.ti_passed = 1 AND arsp.rn_quiz = 1 THEN arsp.i_word_count ELSE 0 END) AS words                
            
        ,ROUND(
           (SUM(CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_questions_correct END) 
              / SUM(CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_questions_presented END)) 
              * 100, 0) AS mastery            
        ,ROUND(
           (SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN arsp.i_questions_correct END) 
              / SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN arsp.i_questions_presented END))
              * 100, 0) AS mastery_fiction
        ,ROUND(
           (SUM(CASE WHEN arsp.ch_fiction_non_fiction != 'F' AND arsp.rn_quiz = 1 THEN arsp.i_questions_correct END)
              / SUM(CASE WHEN arsp.ch_fiction_non_fiction != 'F' AND arsp.rn_quiz = 1 THEN arsp.i_questions_presented END)) 
              * 100, 0) AS mastery_nonfiction            
            
        ,SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN 1 END) AS n_fiction
        ,SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'NF' AND arsp.rn_quiz = 1 THEN 1 END) AS n_nonfic            
        ,ROUND(
           (SUM(CASE WHEN arsp.ch_fiction_non_fiction = 'F' AND arsp.rn_quiz = 1 THEN arsp.i_word_count ELSE 0 END) 
              / SUM(CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_word_count END))
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
   AND arsp.dt_taken BETWEEN rt.start_date AND rt.end_date
  WHERE co.rn_year = 1    
    AND co.schoolid != 999999    
  GROUP BY co.student_number             
          ,co.academic_year              
          ,rt.time_per_name
          ,rt.start_date
          ,rt.end_date
 )
 
SELECT pr.student_number      
      ,pr.academic_year      
      ,pr.reporting_term
      ,pr.start_date
      ,pr.end_date      
      ,pr.words
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
FROM progress_rollup pr
LEFT OUTER JOIN gabby.renaissance.ar_goals goals
  ON pr.student_number = goals.student_number   
 AND pr.academic_year = goals.academic_year
 AND pr.reporting_term = goals.reporting_term  