USE gabby
GO

CREATE OR ALTER VIEW renaissance.ar_progress_to_goals AS

WITH progress_rollup AS (
  SELECT student_number        
        ,academic_year                
        ,reporting_term
        ,start_date
        ,end_date
        ,n_days_elapsed
        ,n_days_term

        ,MAX(dt_taken) AS last_quiz_date
        ,SUM(words_passed) AS words                            
        ,SUM(is_fiction) AS n_fiction
        ,SUM(is_nonfiction) AS n_nonfic
        ,SUM(is_passed) AS n_passed
        ,COUNT(is_total) AS n_total
        ,ROUND(AVG(lexile_calc), 0) AS avg_lexile
        ,ROUND(AVG(book_rating), 2) AS avg_rating      

        ,ROUND((SUM(questions_correct) / SUM(questions_presented)) * 100, 0) AS mastery
        ,ROUND((SUM(questions_correct_f) / SUM(questions_presented_f)) * 100, 0) AS mastery_fiction
        ,ROUND((SUM(questions_correct_nf) / SUM(questions_presented_nf)) * 100, 0) AS mastery_nonfiction      
        ,ROUND((SUM(words_attempted_f) / SUM(words_attempted)) * 100, 0) AS pct_fiction      
  FROM
      (
       SELECT co.student_number        
             ,co.academic_year        
        
             ,CONVERT(VARCHAR(5),rt.time_per_name) AS reporting_term
             ,rt.start_date
             ,rt.end_date
             ,CONVERT(FLOAT,DATEDIFF(DAY, rt.start_date, GETDATE())) AS n_days_elapsed
             ,CONVERT(FLOAT,DATEDIFF(DAY, rt.start_date, rt.end_date)) AS n_days_term

             ,arsp.dt_taken
             ,CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_word_count END AS words_attempted
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ti_passed = 1 THEN arsp.i_word_count ELSE 0 END AS words_passed
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ch_fiction_non_fiction = 'F' THEN arsp.i_word_count ELSE 0 END AS words_attempted_f
             ,CASE WHEN arsp.rn_quiz = 1 THEN fl_lexile_calc END AS lexile_calc
             ,CASE WHEN arsp.rn_quiz = 1 THEN arsp.ti_book_rating END AS book_rating
             ,CASE WHEN arsp.rn_quiz = 1 THEN arsp.ti_passed END AS is_passed
             ,CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_user_id END AS is_total
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ch_fiction_non_fiction = 'F' THEN 1 END AS is_fiction
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ch_fiction_non_fiction = 'NF' THEN 1 END AS is_nonfiction

             ,CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_questions_correct END AS questions_correct
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ch_fiction_non_fiction = 'F' THEN arsp.i_questions_correct END AS questions_correct_f
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ch_fiction_non_fiction != 'F' THEN arsp.i_questions_correct END AS questions_correct_nf
             ,CASE WHEN arsp.rn_quiz = 1 THEN arsp.i_questions_presented END AS questions_presented
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ch_fiction_non_fiction = 'F' THEN arsp.i_questions_presented END AS questions_presented_f
             ,CASE WHEN arsp.rn_quiz = 1 AND arsp.ch_fiction_non_fiction != 'F' THEN arsp.i_questions_presented END AS questions_presented_nf           
       FROM gabby.powerschool.cohort_identifiers_static co
       JOIN gabby.reporting.reporting_terms rt
         ON co.academic_year = rt.academic_year       
        AND co.schoolid = rt.schoolid
        AND rt.identifier = 'AR'     
       LEFT OUTER JOIN gabby.renaissance.ar_studentpractice_identifiers_static arsp
         ON co.student_number = arsp.student_number
        AND arsp.dt_taken BETWEEN rt.start_date AND rt.end_date
       WHERE co.rn_year = 1    
         AND co.schoolid != 999999    
     ) sub
  GROUP BY student_number             
          ,academic_year              
          ,reporting_term
          ,start_date
          ,end_date
          ,n_days_elapsed
          ,n_days_term
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