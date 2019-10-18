USE gabby
GO

CREATE OR ALTER VIEW lit.achieved_by_round AS

WITH roster_scaffold AS (
  SELECT r.student_number
        ,r.schoolid
        ,r.grade_level
        ,r.academic_year        
        
        ,CONVERT(VARCHAR(25),terms.time_per_name) AS reporting_term
        ,CONVERT(VARCHAR(25),terms.alt_name) AS test_round
        ,terms.start_date
        ,terms.end_date
        ,CONVERT(INT,RIGHT(terms.time_per_name, 1)) AS round_num        
        
        ,terms.is_curterm        
  FROM gabby.powerschool.cohort_identifiers_static r
  JOIN gabby.reporting.reporting_terms terms
    ON r.academic_year = terms.academic_year 
   AND r.schoolid = terms.schoolid
   AND terms.identifier = 'LIT'
   AND terms._fivetran_deleted = 0          
  WHERE r.rn_year = 1
 )

,tests AS (
  SELECT student_number
        ,academic_year
        ,schoolid
        ,grade_level
        ,reporting_term
        ,test_round
        ,round_num
        ,start_date
        ,end_date
        ,is_curterm
        
        ,is_fp
        
        ,achv_unique_id
        ,read_lvl
        ,lvl_num
        ,indep_lvl
        ,indep_lvl_num
        ,gleq
        ,gleq_lvl_num
        ,fp_wpmrate
        ,fp_keylever

        ,dna_unique_id
        ,instruct_lvl
        ,instruct_lvl_num
        ,dna_lvl
        ,dna_lvl_num

        ,hard_unique_id
        ,hard_read_lvl
        ,hard_lvl_num

        ,ROW_NUMBER() OVER(
           PARTITION BY sub.student_number
             ORDER BY sub.academic_year DESC, sub.round_num DESC) AS meta_achv_round
  FROM
      (
       /* 2015+ */
       SELECT r.student_number
             ,r.schoolid
             ,r.grade_level
             ,r.academic_year
             ,r.reporting_term
             ,r.test_round
             ,r.round_num
             ,r.start_date
             ,r.end_date
             ,r.is_curterm
        
             ,COALESCE(achv.is_fp, ps.is_fp) AS is_fp

             ,COALESCE(achv.unique_id, ps.unique_id) AS achv_unique_id
             ,COALESCE(achv.read_lvl, ps.read_lvl) AS read_lvl
             ,COALESCE(achv.lvl_num, ps.lvl_num) AS lvl_num
             ,COALESCE(achv.indep_lvl, ps.indep_lvl) AS indep_lvl
             ,COALESCE(achv.indep_lvl_num, ps.indep_lvl_num) AS indep_lvl_num
             ,COALESCE(achv.gleq, ps.gleq) AS gleq
             ,COALESCE(achv.gleq_lvl_num, ps.gleq_lvl_num) AS gleq_lvl_num
             ,COALESCE(achv.fp_wpmrate, ps.fp_wpmrate) AS fp_wpmrate
             ,COALESCE(achv.fp_keylever, ps.fp_keylever) AS fp_keylever

             ,COALESCE(dna.unique_id, ps.unique_id) AS dna_unique_id
             ,COALESCE(dna.instruct_lvl, ps.instruct_lvl) AS instruct_lvl
             ,COALESCE(dna.instruct_lvl_num, ps.instruct_lvl_num) AS instruct_lvl_num
             ,COALESCE(dna.read_lvl, ps.dna_lvl) AS dna_lvl
             ,COALESCE(dna.lvl_num, ps.dna_lvl_num) AS dna_lvl_num

             ,hard.unique_id AS hard_unique_id
             ,hard.read_lvl AS hard_read_lvl
             ,hard.lvl_num AS hard_lvl_num
       FROM roster_scaffold r
       LEFT JOIN gabby.lit.all_test_events_static ps
         ON r.student_number = ps.student_number      
        AND r.academic_year = ps.academic_year
        AND r.test_round = ps.test_round
        AND ps.status = 'Mixed'
        AND ps.curr_round = 1
       LEFT JOIN gabby.lit.all_test_events_static achv 
         ON r.student_number = achv.student_number      
        AND r.academic_year = achv.academic_year
        AND r.test_round = achv.test_round
        AND achv.status = 'Achieved'
        AND achv.curr_round = 1
       LEFT JOIN gabby.lit.all_test_events_static dna 
         ON r.student_number = dna.student_number      
        AND r.academic_year = dna.academic_year
        AND r.test_round = dna.test_round
        AND dna.status = 'Did Not Achieve'
        AND dna.curr_round = 1
       LEFT JOIN gabby.lit.all_test_events_static hard 
         ON r.student_number = hard.student_number      
        AND r.academic_year = hard.academic_year
        AND r.test_round = hard.test_round
        AND hard.status = 'DNA - Hard'
        AND hard.curr_round = 1
       WHERE r.academic_year >= 2015

       UNION ALL

       /* pre-2015 */
       SELECT r.student_number
             ,r.schoolid
             ,r.grade_level
             ,r.academic_year
             ,r.reporting_term
             ,r.test_round
             ,r.round_num
             ,r.start_date
             ,r.end_date
             ,r.is_curterm

             ,achv.is_fp

             ,achv.unique_id AS achv_unique_id
             ,achv.read_lvl
             ,achv.lvl_num
             ,achv.indep_lvl
             ,achv.indep_lvl_num
             ,achv.gleq
             ,achv.gleq_lvl_num
             ,achv.fp_wpmrate
             ,achv.fp_keylever

             ,dna.unique_id AS dna_unique_id
             ,achv.instruct_lvl
             ,achv.instruct_lvl_num
             ,dna.read_lvl AS dna_lvl
             ,dna.lvl_num AS dna_lvl_num

             ,NULL AS hard_unique_id
             ,NULL AS hard_read_lvl
             ,NULL AS hard_lvl_num
       FROM roster_scaffold r
       LEFT JOIN gabby.lit.all_test_events_static achv
         ON r.student_number = achv.student_number
        AND r.academic_year = achv.academic_year
        AND r.test_round = achv.test_round
        AND achv.status = 'Achieved'
        AND achv.curr_round = 1
       LEFT JOIN gabby.lit.all_test_events_static dna
         ON r.student_number = dna.student_number      
        AND r.academic_year = dna.academic_year
        AND r.test_round = dna.test_round
        AND dna.status = 'Did Not Achieve'
        AND dna.curr_round = 1    
       WHERE r.academic_year <= 2014
         AND NOT (r.academic_year = 2014 AND r.schoolid = 133570965 AND r.test_round = 'T3')

       UNION ALL

       SELECT r.student_number
             ,r.schoolid
             ,r.grade_level
             ,r.academic_year
             ,r.reporting_term
             ,r.test_round
             ,r.round_num
             ,r.start_date
             ,r.end_date
             ,r.is_curterm

             ,fp.is_fp

             ,fp.unique_id AS achv_unique_id
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.read_lvl, fp.indep_lvl) ELSE fp.indep_lvl END AS read_lvl
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.lvl_num, fp.indep_lvl_num) ELSE fp.indep_lvl_num END AS lvl_num
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.read_lvl, fp.indep_lvl) ELSE fp.indep_lvl END AS indep_lvl
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.lvl_num, fp.indep_lvl_num) ELSE fp.indep_lvl_num END AS indep_lvl_num
             ,gleq.gleq
             ,gleq.lvl_num AS gleq_lvl_num
             ,fp.fp_wpmrate
             ,fp.fp_keylever
             
             ,fp.unique_id AS dna_unique_id
             ,CONVERT(VARCHAR(1),CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.read_lvl
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN NULL
               ELSE fp.instruct_lvl
              END) AS instruct_lvl
             ,CONVERT(INT,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.lvl_num
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN (gleq.fp_lvl_num + 1)
               ELSE COALESCE(fp.instruct_lvl_num, (gleq.fp_lvl_num + 1))
              END) AS instruct_lvl_num             
             ,CONVERT(VARCHAR(1),CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.read_lvl
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN NULL
               ELSE fp.instruct_lvl
              END) AS dna_lvl
             ,CONVERT(INT,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.lvl_num
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN (gleq.fp_lvl_num + 1)
               ELSE COALESCE(fp.instruct_lvl_num, (gleq.fp_lvl_num + 1))
              END) AS dna_lvl_num

             ,NULL AS hard_unique_id
             ,NULL AS hard_read_lvl
             ,NULL AS hard_lvl_num
       FROM roster_scaffold r  
       JOIN gabby.lit.all_test_events_static fp
         ON r.student_number = fp.student_number
        AND r.academic_year = fp.academic_year
        AND fp.recent_yr = 1
       LEFT JOIN gabby.lit.gleq
         ON CASE WHEN fp.status = 'Achieved' AND fp.indep_lvl IS NULL THEN fp.read_lvl ELSE fp.indep_lvl END = gleq.read_lvl
        AND gleq.testid = 3273
       WHERE r.academic_year = 2014
         AND r.schoolid = 133570965
         AND r.test_round = 'T3'
      ) sub
 )

,achieved AS (
  SELECT tests.student_number
        ,tests.academic_year
        ,tests.schoolid
        ,tests.grade_level                
        ,tests.reporting_term
        ,tests.test_round 
        ,tests.round_num     
        ,tests.start_date
        ,tests.end_date
        ,tests.is_curterm        
                
        ,COALESCE(tests.is_fp,achv_prev.is_fp) AS is_fp
        ,COALESCE(tests.read_lvl,achv_prev.read_lvl) AS read_lvl
        ,COALESCE(tests.lvl_num,achv_prev.lvl_num) AS lvl_num
        ,COALESCE(tests.indep_lvl,achv_prev.indep_lvl) AS indep_lvl
        ,COALESCE(tests.indep_lvl_num,achv_prev.indep_lvl_num) AS indep_lvl_num
        ,COALESCE(tests.instruct_lvl,achv_prev.instruct_lvl) AS instruct_lvl
        ,COALESCE(tests.instruct_lvl_num,achv_prev.instruct_lvl_num) AS instruct_lvl_num
        ,COALESCE(tests.gleq,achv_prev.gleq) AS gleq
        ,COALESCE(tests.gleq_lvl_num,achv_prev.gleq_lvl_num) AS gleq_lvl_num
        ,COALESCE(tests.fp_wpmrate,achv_prev.fp_wpmrate) AS fp_wpmrate
        ,COALESCE(tests.fp_keylever,achv_prev.fp_keylever) AS fp_keylever                
        ,COALESCE(tests.achv_unique_id, achv_prev.achv_unique_id) AS achv_unique_id                
        
        ,ROW_NUMBER() OVER(
          PARTITION BY tests.student_number, tests.meta_achv_round
            ORDER BY achv_prev.meta_achv_round) AS rn
  FROM tests 
  LEFT JOIN tests achv_prev 
    ON tests.student_number = achv_prev.student_number
   AND tests.meta_achv_round < achv_prev.meta_achv_round
   AND achv_prev.read_lvl IS NOT NULL                       
 )

,dna AS (
  SELECT tests.academic_year        
        ,tests.student_number        
        ,tests.test_round
        ,tests.round_num                             
        
        ,COALESCE(tests.dna_lvl, dna_prev.dna_lvl) AS dna_lvl
        ,COALESCE(tests.dna_lvl_num, dna_prev.dna_lvl_num) AS dna_lvl_num
        ,COALESCE(tests.dna_unique_id, dna_prev.dna_unique_id) AS dna_unique_id
                
        ,ROW_NUMBER() OVER(
          PARTITION BY tests.student_number, tests.meta_achv_round
            ORDER BY dna_prev.meta_achv_round) AS rn
  FROM tests 
  LEFT JOIN tests dna_prev 
    ON tests.student_number = dna_prev.student_number           
   AND tests.meta_achv_round < dna_prev.meta_achv_round
   AND dna_prev.dna_lvl IS NOT NULL                    
   AND tests.start_date <= CONVERT(DATE,GETDATE()) /* preserves the scaffold but will not carry scores to a future term */
 )

,hard AS (
  SELECT tests.academic_year        
        ,tests.student_number        
        ,tests.test_round
        ,tests.round_num                             
        
        ,COALESCE(tests.hard_read_lvl, hard_prev.hard_read_lvl) AS hard_lvl
        ,COALESCE(tests.hard_lvl_num, hard_prev.hard_lvl_num) AS hard_lvl_num
        ,COALESCE(tests.hard_unique_id, hard_prev.hard_unique_id) AS hard_unique_id
                
        ,ROW_NUMBER() OVER(
          PARTITION BY tests.student_number, tests.meta_achv_round
            ORDER BY hard_prev.meta_achv_round) AS rn
  FROM tests 
  LEFT JOIN tests hard_prev 
    ON tests.student_number = hard_prev.student_number           
   AND tests.meta_achv_round < hard_prev.meta_achv_round
   AND hard_prev.hard_lvl_num IS NOT NULL                    
   AND tests.start_date <= CONVERT(DATE,GETDATE()) /* preserves the scaffold but will not carry scores to a future term */
 )

/* falls back to most recently achieved reading level for each round, if NULL */
SELECT academic_year
      ,schoolid
      ,grade_level
      ,student_number      
      ,reporting_term
      ,test_round
      ,start_date
      ,end_date
      ,is_curterm
      ,read_lvl
      ,instruct_lvl
      ,instruct_lvl_num
      ,indep_lvl
      ,indep_lvl_num
      ,dna_lvl
      ,dna_lvl_num
      ,hard_lvl
      ,hard_lvl_num
      ,prev_read_lvl
      ,prev_lvl_num      
      ,gleq      
      ,lvl_num      
      ,fp_wpmrate
      ,fp_keylever
      ,goal_lvl      
      ,goal_num         
      ,default_goal_lvl      
      ,default_goal_num         
      ,NULL AS natl_goal_lvl
      ,NULL AS natl_goal_num 
      ,levels_behind
      ,achv_unique_id
      ,dna_unique_id
      ,hard_unique_id
      ,is_new_test

      ,CASE
        WHEN lvl_num >= 26 THEN 1
        WHEN lvl_num >= goal_num THEN 1 
        WHEN lvl_num < goal_num THEN 0        
       END AS met_goal
      ,CASE
        WHEN lvl_num >= 26 THEN 1
        WHEN lvl_num >= default_goal_num THEN 1 
        WHEN lvl_num < default_goal_num THEN 0
       END AS met_default_goal
      ,NULL AS met_natl_goal
      ,CASE
        WHEN lvl_num >= 26 THEN 'Achieved Z'
        WHEN lvl_num - goal_num > 0 THEN 'Above Target'
        WHEN lvl_num - goal_num = 0 THEN 'Target'
        WHEN lvl_num - goal_num = -1 THEN 'Approaching'
        WHEN lvl_num - goal_num = -2 THEN 'Below'
        WHEN lvl_num - goal_num < -2 THEN 'Far Below'
       END AS goal_status
      ,CASE 
        WHEN gleq = prev_gleq THEN 0
        WHEN gleq_lvl_num > prev_gleq_lvl_num THEN 1 
        WHEN gleq_lvl_num <= prev_gleq_lvl_num THEN 0        
       END AS moved_levels      
      
      ,MAX(CASE WHEN sub.reporting_term = sub.max_reporting_term_ytd THEN sub.lvl_num END) OVER(PARTITION BY sub.student_number, sub.academic_year)
         - MAX(CASE WHEN sub.reporting_term = sub.min_reporting_term_ytd THEN sub.lvl_num END) OVER(PARTITION BY sub.student_number, sub.academic_year)
         AS n_levels_moved_y1
      ,MAX(CASE WHEN sub.reporting_term = sub.max_reporting_term_ytd THEN sub.gleq END) OVER(PARTITION BY sub.student_number, sub.academic_year)
         - MAX(CASE WHEN sub.reporting_term = sub.min_reporting_term_ytd THEN sub.gleq END) OVER(PARTITION BY sub.student_number, sub.academic_year)
         AS gleq_growth_y1
      
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year
           ORDER BY start_date ASC) AS rn_round_asc
FROM
    (
     SELECT sub.academic_year
           ,sub.schoolid
           ,sub.grade_level
           ,sub.student_number           
           ,sub.reporting_term
           ,sub.test_round
           ,sub.round_num
           ,sub.start_date
           ,sub.end_date
           ,sub.is_curterm

           ,sub.achv_unique_id      
           ,sub.read_lvl           
           ,sub.lvl_num            
           ,sub.indep_lvl
           ,sub.indep_lvl_num
           ,sub.gleq   
           ,sub.gleq_lvl_num        
           ,sub.fp_wpmrate
           ,sub.fp_keylever

           ,sub.dna_unique_id      
           ,sub.instruct_lvl
           ,sub.instruct_lvl_num                
           ,sub.dna_lvl
           ,sub.dna_lvl_num                     

           ,sub.hard_unique_id
           ,sub.hard_lvl
           ,sub.hard_lvl_num
           
           ,sub.is_new_test
           ,MIN(CASE WHEN sub.lvl_num IS NOT NULL THEN sub.reporting_term END) OVER(PARTITION BY sub.student_number, sub.academic_year) AS min_reporting_term_ytd
           ,MAX(CASE WHEN GETDATE() >= sub.start_date THEN sub.reporting_term END) OVER(PARTITION BY sub.student_number, sub.academic_year) AS max_reporting_term_ytd

           ,CASE
             WHEN sub.academic_year >= 2018 THEN sub.fp_read_lvl
             WHEN (sub.fp_read_lvl IS NOT NULL AND sub.step_read_lvl IS NOT NULL)
              AND sub.is_fp = 1 
                    THEN sub.fp_read_lvl
             WHEN (sub.fp_read_lvl IS NOT NULL AND sub.step_read_lvl IS NOT NULL)
              AND sub.is_fp = 0 
                    THEN sub.step_read_lvl
             ELSE COALESCE(sub.fp_read_lvl, sub.step_read_lvl)
            END AS default_goal_lvl
           
           ,CASE
             WHEN sub.academic_year >= 2018 THEN sub.fp_lvl_num
             WHEN (sub.fp_lvl_num IS NOT NULL AND sub.step_lvl_num IS NOT NULL)
              AND sub.is_fp = 1 
                    THEN sub.fp_lvl_num
             WHEN (sub.fp_lvl_num IS NOT NULL AND sub.step_lvl_num IS NOT NULL)
              AND sub.is_fp = 0 
                    THEN sub.step_lvl_num
             ELSE COALESCE(sub.fp_lvl_num, sub.step_lvl_num)
            END AS default_goal_num            

           ,sub.indiv_goal_lvl
           ,sub.indiv_lvl_num

           ,LAG(sub.read_lvl, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.start_date ASC) AS prev_read_lvl
           ,LAG(sub.lvl_num, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.start_date ASC) AS prev_lvl_num           
           ,LAG(sub.gleq, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.start_date ASC) AS prev_gleq
           ,LAG(sub.gleq_lvl_num, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.start_date ASC) AS prev_gleq_lvl_num           
           
           ,COALESCE(sub.indiv_goal_lvl
                    ,CASE
                      WHEN sub.academic_year >= 2018 THEN sub.fp_read_lvl
                      WHEN (sub.fp_read_lvl IS NOT NULL AND sub.step_read_lvl IS NOT NULL)
                       AND sub.is_fp = 1 
                             THEN sub.fp_read_lvl
                      WHEN (sub.fp_read_lvl IS NOT NULL AND sub.step_read_lvl IS NOT NULL)
                       AND sub.is_fp = 0 
                             THEN sub.step_read_lvl
                      ELSE COALESCE(sub.fp_read_lvl, sub.step_read_lvl)
                     END) AS goal_lvl
           
           ,COALESCE(sub.indiv_lvl_num
                    ,CASE
                      WHEN sub.academic_year >= 2018 THEN sub.fp_lvl_num
                      WHEN (sub.fp_lvl_num IS NOT NULL AND sub.step_lvl_num IS NOT NULL)
                       AND sub.is_fp = 1 
                             THEN sub.fp_lvl_num
                      WHEN (sub.fp_lvl_num IS NOT NULL AND sub.step_lvl_num IS NOT NULL)
                       AND sub.is_fp = 0 
                             THEN sub.step_lvl_num
                      ELSE COALESCE(sub.fp_lvl_num, sub.step_lvl_num)
                     END) AS goal_num                                                 
           
           ,sub.lvl_num - COALESCE(sub.lvl_num
                                  ,CASE
                                    WHEN sub.academic_year >= 2018 THEN sub.fp_lvl_num
                                    WHEN (sub.fp_lvl_num IS NOT NULL AND sub.step_lvl_num IS NOT NULL)
                                     AND sub.is_fp = 1 
                                           THEN sub.fp_lvl_num
                                    WHEN (sub.fp_lvl_num IS NOT NULL AND sub.step_lvl_num IS NOT NULL)
                                     AND sub.is_fp = 0 
                                           THEN sub.step_lvl_num
                                    ELSE COALESCE(sub.fp_lvl_num, sub.step_lvl_num)
                                   END) AS levels_behind                      
     FROM
         (
          SELECT achieved.academic_year
                ,achieved.schoolid
                ,achieved.grade_level
                ,achieved.student_number                      
                ,achieved.reporting_term
                ,achieved.test_round 
                ,achieved.round_num     
                ,achieved.start_date
                ,achieved.end_date
                ,achieved.is_curterm
                ,achieved.is_fp                
                ,achieved.read_lvl
                ,achieved.lvl_num
                ,achieved.indep_lvl
                ,achieved.indep_lvl_num
                ,achieved.instruct_lvl
                ,achieved.instruct_lvl_num
                ,achieved.gleq
                ,achieved.gleq_lvl_num    
                ,achieved.fp_wpmrate
                ,achieved.fp_keylever                
                ,achieved.achv_unique_id

                ,dna.dna_lvl
                ,dna.dna_lvl_num
                ,dna.dna_unique_id

                ,hard.hard_lvl
                ,hard.hard_lvl_num
                ,hard.hard_unique_id

                ,CONVERT(VARCHAR(5),goals.fp_read_lvl) AS fp_read_lvl
                ,CONVERT(VARCHAR(5),goals.step_read_lvl) AS step_read_lvl
                ,CONVERT(INT,goals.fp_lvl_num) AS fp_lvl_num
                ,CONVERT(INT,goals.step_lvl_num) AS step_lvl_num

                ,CONVERT(VARCHAR(5),indiv.goal) AS indiv_goal_lvl
                ,CONVERT(INT,indiv.lvl_num) AS indiv_lvl_num

                ,CASE 
                  WHEN achieved.academic_year = atid.academic_year AND achieved.round_num = atid.round_num THEN 1 
                  WHEN achieved.academic_year = dna.academic_year AND achieved.round_num = dna.round_num THEN 1 
                  ELSE 0 
                 END AS is_new_test
          FROM achieved
          LEFT JOIN gabby.lit.all_test_events_static atid 
            ON achieved.achv_unique_id = atid.unique_id
           AND atid.status = 'Achieved'
          LEFT JOIN dna
            ON achieved.student_number = dna.student_number
           AND achieved.academic_year = dna.academic_year
           AND achieved.round_num = dna.round_num
           AND dna.rn = 1
          LEFT JOIN hard
            ON achieved.student_number = hard.student_number
           AND achieved.academic_year = hard.academic_year
           AND achieved.round_num = hard.round_num
           AND hard.rn = 1
          LEFT JOIN gabby.lit.network_goals goals 
            ON achieved.grade_level = goals.grade_level
           AND achieved.round_num = goals.round_num
           AND goals.norms_year = 2019
          LEFT JOIN gabby.lit.individualized_goals indiv 
            ON achieved.student_number = indiv.student_number
           AND achieved.test_round = indiv.test_round
           AND achieved.academic_year = indiv.academic_year 
          WHERE achieved.rn = 1
         ) sub    
    ) sub