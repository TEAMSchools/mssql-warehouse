USE gabby
GO

CREATE OR ALTER VIEW tableau.lit_tracker AS

SELECT co.school_name
      ,co.school_level
      ,co.student_number
      ,co.lastfirst AS student_name
      ,co.grade_level      
      ,co.team
      ,co.advisor_name
      ,co.academic_year            
      ,co.IEP_status      
      ,co.LEP_status
      ,co.enroll_status            
      ,co.cohort
      
      ,CASE WHEN sp.programid IS NOT NULL THEN 1 ELSE 0 END AS is_americorps
      
      ,term.lit AS lit_term
      ,CASE
        WHEN co.academic_year >= 2015 THEN REPLACE(term.ar,'AR','Q')
        ELSE REPLACE(term.ar,'AR','Hex ') 
       END AS AR_term
      
      ,achv.reporting_term
      ,achv.start_date AS lit_term_start_date
      ,achv.end_date AS lit_term_end_date
      ,achv.is_curterm
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.GLEQ      
      ,achv.dna_lvl
      ,achv.dna_lvl_num
      ,achv.instruct_lvl
      ,achv.instruct_lvl_num
      ,achv.indep_lvl
      ,achv.indep_lvl_num
      ,achv.prev_read_lvl
      ,achv.prev_lvl_num            
      ,achv.is_new_test
      ,achv.moved_levels    
      ,achv.achv_unique_id AS unique_id
      ,achv.dna_unique_id        
      ,achv.n_levels_moved_y1
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.natl_goal_lvl
      ,achv.natl_goal_num
      ,achv.default_goal_lvl
      ,achv.default_goal_num      
      ,achv.met_goal
      ,achv.met_natl_goal
      ,achv.met_default_goal      
      ,achv.lvl_num - achv.goal_num AS distance_from_goal
      
      ,atid.is_fp
      ,atid.status
      ,atid.color
      ,atid.genre
      
      ,COALESCE(achv.fp_keylever, dtid.fp_keylever) AS fp_keylever      
      ,CASE 
        WHEN atid.test_date >= dtid.test_date THEN atid.test_date 
        ELSE COALESCE(dtid.test_date, atid.test_date)
       END AS test_date      
      ,COALESCE(atid.test_administered_by, gr.gr_teacher) AS test_administered_by
      
      /* component data */      
      ,long.domain AS component_domain
      ,long.label AS component_strand
      ,long.specific_label AS component_strand_specific
      ,long.score AS component_score
      ,long.benchmark AS component_benchmark
      ,long.is_prof AS component_prof
      ,long.margin AS component_margin            
      ,long.dna_filter

      /* AR */      
      ,ar.words
      ,ar.mastery
      ,ar.pct_fiction
      ,ar.avg_lexile
      ,ar.n_passed
      ,ar.n_total
      ,ar.stu_status_words AS status_words
      ,CASE WHEN ar.words_goal < 0 THEN NULL ELSE ar.words_goal END AS words_goal
      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.academic_year, term.lit, term.ar, achv.achv_unique_id
           ORDER BY achv.achv_unique_id) AS rn_test
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.spenrollments_gen sp
  ON co.studentid = sp.studentid
 AND co.academic_year = sp.academic_year
 AND sp.programid = 5224
JOIN gabby.reporting.reporting_term_map term
  ON co.school_level = term.school_level
 AND co.academic_year BETWEEN term.min_year AND term.max_year 
JOIN gabby.lit.achieved_by_round_static achv
  ON co.student_number = achv.student_number
 AND co.academic_year = achv.academic_year
 AND term.lit = achv.test_round
 AND achv.start_date <= GETDATE()
LEFT JOIN gabby.lit.all_test_events_static atid
  ON co.student_number = atid.student_number
 AND achv.achv_unique_id = atid.unique_id 
 AND atid.status = 'Achieved'
LEFT JOIN gabby.lit.all_test_events_static dtid
  ON co.student_number = dtid.student_number
 AND achv.dna_unique_id = dtid.unique_id 
 AND dtid.status = 'Did Not Achieve'
LEFT JOIN gabby.lit.component_proficiency_long_static long
  ON co.student_number = long.student_number
 AND achv.dna_unique_id = long.unique_id
 AND long.status != 'Achieved'
LEFT JOIN gabby.renaissance.ar_progress_to_goals ar
  ON co.student_number = ar.student_number
 AND co.academic_year = ar.academic_year
 AND term.ar = ar.reporting_term 
 AND ar.start_date <= GETDATE()
 AND ar.n_total > 0
LEFT JOIN gabby.lit.guided_reading_roster gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year
 AND term.lit = gr.test_round
WHERE co.rn_year = 1
  AND co.reporting_schoolid NOT IN (999999, 5173)