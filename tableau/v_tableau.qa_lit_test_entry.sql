USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_lit_test_entry AS

/* student identifiers */
SELECT co.school_name
      ,co.school_level      
      ,co.lastfirst AS student_name
      ,co.grade_level      
      ,co.team      
      ,co.academic_year            
      ,co.iep_status      
      ,co.enroll_status      
            
      ,CONVERT(VARCHAR(5),term.alt_name) AS lit_term
      ,CASE 
        WHEN achv.start_date >= CONVERT(DATE,GETDATE()) THEN NULL 
        ELSE co.student_number 
       END AS student_number      
      
      /* test identifiers */      
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.dna_lvl
      ,achv.dna_lvl_num
      ,achv.instruct_lvl
      ,achv.instruct_lvl_num
      ,achv.indep_lvl
      ,achv.indep_lvl_num
      ,achv.prev_read_lvl
      ,achv.prev_lvl_num
      ,achv.GLEQ      
      ,achv.fp_keylever
      ,achv.is_new_test
      ,achv.moved_levels      
      ,SUM(CASE WHEN achv.test_round IN ('DR','BOY') THEN NULL ELSE achv.moved_levels END) OVER(
         PARTITION BY co.student_number, co.academic_year 
           ORDER BY achv.start_date ASC) AS n_levels_moved_y1

      ,testid.academic_year AS achvtest_academic_year
      ,testid.test_round AS achvtest_test_round
      ,testid.test_date
      ,testid.status
      ,testid.color
      ,testid.genre
      ,testid.is_fp
      
      ,dna.academic_year AS dnatest_academic_year
      ,dna.test_round AS dnatest_test_round
      ,dna.test_date AS dna_date
      ,CASE                      
        WHEN achv.lvl_num IS NULL THEN 3
        WHEN achv.lvl_num >= 26 THEN 1
        WHEN achv.test_round IN ('BOY','DR') 
         AND testid.test_round IN ('EOY','Q4','T3')
         AND achv.academic_year = testid.academic_year + 1 
               THEN 1
        WHEN achv.test_round = testid.test_round 
         AND achv.academic_year = testid.academic_year 
               THEN 1
        WHEN achv.test_round IN ('BOY','DR') 
         AND dna.test_round IN ('EOY','Q4','T3') 
         AND achv.academic_year = dna.academic_year + 1 
               THEN 2
        WHEN achv.test_round = dna.test_round AND achv.academic_year = dna.academic_year THEN 2        
        ELSE 3
       END AS test_audit

      /* progress to goals */
      ,achv.is_curterm
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.natl_goal_lvl
      ,achv.natl_goal_num
      ,achv.default_goal_lvl
      ,achv.default_goal_num      
      ,achv.lvl_num - achv.goal_num AS distance_from_goal            
      ,achv.met_goal AS met_goal
      ,achv.met_natl_goal AS met_natl_goal
      ,achv.met_default_goal AS met_default_goal  
      ,achv.achv_unique_id
      ,achv.dna_unique_id
FROM gabby.powerschool.cohort_identifiers_static co 
JOIN gabby.reporting.reporting_terms term
  ON co.schoolid = term.schoolid
 AND co.academic_year = term.academic_year
 AND term.identifier = 'LIT'
 AND term.start_date <= CONVERT(DATE,GETDATE())
LEFT JOIN gabby.lit.achieved_by_round_static achv
  ON co.student_number = achv.student_number
 AND co.academic_year = achv.academic_year
 AND term.alt_name = achv.test_round
 AND achv.start_date <= CONVERT(DATE,GETDATE())
LEFT JOIN gabby.lit.all_test_events_static testid 
  ON co.student_number = testid.student_number
 AND achv.achv_unique_id = testid.unique_id 
LEFT JOIN gabby.lit.all_test_events_static dna 
  ON co.student_number = dna.student_number
 AND achv.dna_unique_id = dna.unique_id 
WHERE co.rn_year = 1
  AND co.grade_level != 99
  AND co.enroll_status = 0
  AND co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)  