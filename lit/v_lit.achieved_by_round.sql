USE gabby
GO

ALTER VIEW lit.achieved_by_round AS

WITH roster_scaffold AS (
  SELECT r.student_number
        ,r.schoolid
        ,r.grade_level
        ,r.academic_year        
        
        ,terms.time_per_name AS reporting_term
        ,terms.alt_name AS test_round
        ,CONVERT(DATE,terms.start_date) AS start_date
        ,CONVERT(DATE,terms.end_date) AS end_date
        ,CONVERT(INT,RIGHT(terms.time_per_name, 1)) AS round_num        
        
        ,CASE 
          WHEN CONVERT(DATE,GETDATE()) BETWEEN CONVERT(DATE,terms.start_date) AND CONVERT(DATE,terms.end_date) THEN 1 
          WHEN MAX(CASE 
                    WHEN CONVERT(DATE,terms.start_date) <= CONVERT(DATE,GETDATE()) THEN CONVERT(DATE,terms.start_date) 
                   END) OVER(PARTITION BY r.schoolid, r.academic_year) = terms.start_date 
                 THEN 1
          ELSE 0 
         END AS is_curterm        
  FROM gabby.powerschool.cohort_identifiers_static r
  JOIN gabby.reporting.reporting_terms terms
    ON r.academic_year = terms.academic_year 
   AND r.schoolid = terms.schoolid
   AND r.exitdate > CONVERT(DATE,terms.start_date)
   AND terms.identifier = 'LIT'          
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
        ,instruct_lvl
        ,instruct_lvl_num
        ,gleq
        ,fp_wpmrate
        ,fp_keylever
        ,dna_unique_id
        ,dna_lvl
        ,dna_lvl_num
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
             ,COALESCE(achv.read_lvl, ps.read_lvl) AS read_lvl
             ,COALESCE(achv.lvl_num, ps.lvl_num) AS lvl_num
             ,COALESCE(achv.indep_lvl, ps.indep_lvl) AS indep_lvl
             ,COALESCE(achv.indep_lvl_num, ps.indep_lvl_num) AS indep_lvl_num
             ,COALESCE(dna.instruct_lvl, ps.instruct_lvl) AS instruct_lvl
             ,COALESCE(dna.instruct_lvl_num, ps.instruct_lvl_num) AS instruct_lvl_num
             ,COALESCE(achv.GLEQ, ps.GLEQ) AS GLEQ
             ,COALESCE(achv.fp_wpmrate, ps.fp_wpmrate) AS fp_wpmrate
             ,COALESCE(achv.fp_keylever, ps.fp_keylever) AS fp_keylever
             ,COALESCE(dna.read_lvl, ps.dna_lvl) AS dna_lvl
             ,COALESCE(dna.lvl_num, ps.dna_lvl_num) AS dna_lvl_num
             ,COALESCE(achv.unique_id, ps.unique_id) AS achv_unique_id
             ,COALESCE(dna.unique_id, ps.unique_id) AS dna_unique_id
       FROM roster_scaffold r
       LEFT OUTER JOIN gabby.lit.all_test_events_static ps
         ON r.student_number = ps.student_number      
        AND r.academic_year = ps.academic_year
        AND r.test_round = ps.test_round
        AND ps.status = 'Mixed'
        AND ps.curr_round = 1
       LEFT OUTER JOIN gabby.lit.all_test_events_static achv 
         ON r.student_number = achv.student_number      
        AND r.academic_year = achv.academic_year
        AND r.test_round = achv.test_round
        AND achv.status = 'Achieved'
        AND achv.curr_round = 1
       LEFT OUTER JOIN gabby.lit.all_test_events_static dna 
         ON r.student_number = dna.student_number      
        AND r.academic_year = dna.academic_year
        AND r.test_round = dna.test_round
        AND dna.status = 'Did Not Achieve'
        AND dna.curr_round = 1
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
             ,achv.read_lvl
             ,achv.lvl_num
             ,achv.indep_lvl
             ,achv.indep_lvl_num
             ,achv.instruct_lvl
             ,achv.instruct_lvl_num
             ,achv.gleq
             ,achv.fp_wpmrate
             ,achv.fp_keylever
             ,dna.read_lvl AS dna_lvl
             ,dna.lvl_num AS dna_lvl_num
             ,achv.unique_id AS achv_unique_id
             ,dna.unique_id AS dna_unique_id
       FROM roster_scaffold r  
       LEFT OUTER JOIN gabby.lit.all_test_events_static achv
         ON r.student_number = achv.student_number      
        AND r.academic_year = achv.academic_year
        AND r.test_round = achv.test_round
        AND achv.status = 'Achieved'
        AND achv.curr_round = 1
       LEFT OUTER JOIN gabby.lit.all_test_events_static dna
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
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.read_lvl, fp.indep_lvl) ELSE fp.indep_lvl END AS read_lvl
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.lvl_num, fp.indep_lvl_num) ELSE fp.indep_lvl_num END AS lvl_num
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.read_lvl, fp.indep_lvl) ELSE fp.indep_lvl END AS indep_lvl
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.lvl_num, fp.indep_lvl_num) ELSE fp.indep_lvl_num END AS indep_lvl_num        
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.read_lvl
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN gleq.instruct_lvl
               ELSE COALESCE(fp.instruct_lvl, gleq.instruct_lvl)
              END AS instruct_lvl
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.lvl_num
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN (gleq.fp_lvl_num + 1)
               ELSE COALESCE(fp.instruct_lvl_num, (gleq.fp_lvl_num + 1))
              END AS instruct_lvl_num
             ,gleq.GLEQ        
             ,fp.fp_wpmrate
             ,fp.fp_keylever
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.read_lvl
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN gleq.instruct_lvl
               ELSE COALESCE(fp.instruct_lvl, gleq.instruct_lvl)
              END AS dna_lvl
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.lvl_num
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN (gleq.fp_lvl_num + 1)
               ELSE COALESCE(fp.instruct_lvl_num, (gleq.fp_lvl_num + 1))
              END AS dna_lvl_num
             ,fp.unique_id AS achv_unique_id
             ,fp.unique_id AS dna_unique_id            
       FROM roster_scaffold r  
       JOIN gabby.lit.all_test_events_static fp        
         ON r.student_number = fp.student_number
        AND r.academic_year = fp.academic_year
        AND fp.recent_yr = 1    
       LEFT OUTER JOIN gabby.lit.gleq
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
        ,COALESCE(tests.GLEQ,achv_prev.GLEQ) AS GLEQ
        ,COALESCE(tests.fp_wpmrate,achv_prev.fp_wpmrate) AS fp_wpmrate
        ,COALESCE(tests.fp_keylever,achv_prev.fp_keylever) AS fp_keylever                
        ,COALESCE(tests.achv_unique_id, achv_prev.achv_unique_id) AS achv_unique_id                
        
        ,ROW_NUMBER() OVER(
          PARTITION BY tests.student_number, tests.meta_achv_round
            ORDER BY achv_prev.meta_achv_round) AS rn
  FROM tests 
  LEFT OUTER JOIN tests achv_prev 
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
  LEFT OUTER JOIN tests dna_prev 
    ON tests.student_number = dna_prev.student_number           
   AND tests.meta_achv_round < dna_prev.meta_achv_round
   AND dna_prev.dna_lvl IS NOT NULL                    
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
      ,prev_read_lvl
      ,prev_lvl_num      
      ,GLEQ      
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
      ,CONVERT(NVARCHAR(64),achv_unique_id) AS achv_unique_id
      ,CONVERT(NVARCHAR(64),dna_unique_id) AS dna_unique_id
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
        WHEN lvl_num >= 26 THEN 'On Track'
        WHEN lvl_num >= goal_num THEN 'On Track'
        WHEN lvl_num < goal_num THEN 'Off Track'        
       END AS goal_status
      ,CASE 
        WHEN lvl_num > prev_lvl_num THEN 1 
        WHEN lvl_num <= prev_lvl_num THEN 0        
       END AS moved_levels
      ,SUM(CASE             
            WHEN round_num = 1 THEN 0 
            WHEN lvl_num > prev_lvl_num THEN 1 
            WHEN lvl_num <= prev_lvl_num THEN 0        
           END) OVER(PARTITION BY student_number, academic_year ORDER BY start_date ASC) AS n_levels_moved_y1
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
           ,sub.read_lvl           
           ,sub.lvl_num            
           ,sub.instruct_lvl
           ,sub.instruct_lvl_num     
           ,sub.indep_lvl
           ,sub.indep_lvl_num
           ,sub.dna_lvl
           ,sub.dna_lvl_num
           ,sub.GLEQ           
           ,sub.fp_wpmrate
           ,sub.fp_keylever
           ,sub.achv_unique_id      
           ,sub.dna_unique_id      

           ,CASE
             WHEN sub.is_fp = 1 THEN goals.fp_read_lvl
             WHEN sub.is_fp = 0 THEN goals.step_read_lvl
            END AS default_goal_lvl
           ,CASE
             WHEN sub.is_fp = 1 THEN goals.fp_lvl_num
             WHEN sub.is_fp = 0 THEN goals.step_lvl_num
            END AS default_goal_num           

           ,indiv.goal AS indiv_goal_lvl
           ,indiv.lvl_num AS indiv_lvl_num

           ,LAG(sub.read_lvl, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.academic_year ASC, sub.start_date ASC) AS prev_read_lvl
           ,LAG(sub.lvl_num, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.academic_year ASC, sub.start_date ASC) AS prev_lvl_num           
           ,COALESCE(indiv.goal
                    ,CASE
                      WHEN sub.is_fp = 1 THEN goals.fp_read_lvl
                      WHEN sub.is_fp = 0 THEN goals.step_read_lvl
                     END) AS goal_lvl
           ,COALESCE(indiv.lvl_num
                    ,CASE
                      WHEN sub.is_fp = 1 THEN goals.fp_lvl_num
                      WHEN sub.is_fp = 0 THEN goals.step_lvl_num
                     END) AS goal_num                                      
           
           ,sub.lvl_num - COALESCE(indiv.lvl_num
                                  ,CASE
                                    WHEN sub.is_fp = 1 THEN goals.fp_lvl_num
                                    WHEN sub.is_fp = 0 THEN goals.step_lvl_num
                                   END) AS levels_behind
           
           ,CASE 
             WHEN sub.academic_year = lit.academic_year AND sub.round_num = lit.round_num THEN 1 
             ELSE 0
            END AS is_new_test
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
                ,achieved.fp_wpmrate
                ,achieved.fp_keylever                
                ,achieved.achv_unique_id
                
                ,dna.dna_lvl
                ,dna.dna_lvl_num
                ,dna.dna_unique_id                
          FROM achieved
          LEFT OUTER JOIN dna
            ON achieved.student_number = dna.student_number
           AND achieved.academic_year = dna.academic_year
           AND achieved.round_num = dna.round_num
           AND dna.rn = 1
          WHERE achieved.rn = 1
         ) sub
     LEFT OUTER JOIN gabby.lit.network_goals goals 
       ON sub.grade_level = goals.grade_level
      AND sub.test_round = goals.test_round
      AND sub.academic_year = goals.norms_year
     LEFT OUTER JOIN gabby.lit.individualized_goals indiv 
       ON sub.student_number = indiv.student_number
      AND sub.test_round = indiv.test_round
      AND sub.academic_year = indiv.academic_year
     LEFT OUTER JOIN gabby.lit.all_test_events_static lit 
       ON sub.achv_unique_id = lit.unique_id
      AND lit.status != 'Did Not Achieve'     
    ) sub