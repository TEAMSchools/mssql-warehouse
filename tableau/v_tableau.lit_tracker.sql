USE gabby
GO

CREATE OR ALTER VIEW tableau.lit_tracker AS

SELECT co.school_name
      ,co.school_level
      ,co.student_number
      ,co.lastfirst AS student_name
      ,co.grade_level
      ,co.team
      ,co.academic_year
      ,co.iep_status
      ,co.lep_status
      ,co.enroll_status
      ,co.region
      ,co.is_pathways
      ,co.c_504_status

      ,term.lit AS lit_term
      ,CASE
        WHEN co.academic_year >= 2015 THEN REPLACE(term.ar,'AR','Q')
        ELSE REPLACE(term.ar,'AR','Hex ') 
       END AS AR_term

      ,achv.is_curterm
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.GLEQ
      ,achv.dna_lvl
      ,achv.dna_lvl_num
      ,achv.moved_levels
      ,achv.achv_unique_id AS unique_id
      ,achv.dna_unique_id
      ,achv.n_levels_moved_y1
      ,achv.gleq_growth_y1
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.met_goal
      ,achv.hard_lvl
      ,achv.goal_status
      ,achv.lvl_num - achv.goal_num AS distance_from_goal

      ,atid.is_fp
      ,atid.genre

      ,(SELECT MAX(v) FROM (VALUES (atid.test_date), (dtid.test_date), (htid.test_date)) AS val(v)) AS test_date
      ,atid.test_administered_by

      /* component data */
      ,long.domain AS component_domain
      ,long.[label] AS component_strand
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
      ,ar.n_passed
      ,ar.n_total
      ,CASE WHEN ar.words_goal < 0 THEN NULL ELSE ar.words_goal END AS words_goal

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.academic_year, term.lit, term.ar, achv.achv_unique_id
           ORDER BY achv.achv_unique_id) AS rn_test
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.reporting.reporting_term_map term
  ON co.school_level = term.school_level COLLATE Latin1_General_BIN
 AND co.academic_year BETWEEN term.min_year AND term.max_year 
JOIN gabby.lit.achieved_by_round_static achv
  ON co.student_number = achv.student_number
 AND co.academic_year = achv.academic_year
 AND term.lit = achv.test_round
 AND achv.[start_date] <= GETDATE()
LEFT JOIN gabby.lit.all_test_events_static atid
  ON achv.achv_unique_id = atid.unique_id
LEFT JOIN gabby.lit.all_test_events_static dtid
  ON achv.dna_unique_id = dtid.unique_id
LEFT JOIN gabby.lit.all_test_events_static htid
  ON achv.hard_unique_id = htid.unique_id
LEFT JOIN gabby.lit.component_proficiency_long_static long
  ON achv.dna_unique_id = long.unique_id
LEFT JOIN gabby.renaissance.ar_progress_to_goals ar
  ON co.student_number = ar.student_number
 AND co.academic_year = ar.academic_year
 AND term.ar = ar.reporting_term 
 AND ar.[start_date] <= GETDATE()
 AND ar.n_total > 0
WHERE co.rn_year = 1
  AND co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 3)
  AND co.grade_level <> 99
  AND co.school_level <> 'OD'
