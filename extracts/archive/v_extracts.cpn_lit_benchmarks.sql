USE gabby
GO

CREATE OR ALTER VIEW extracts.cpn_lit_benchmarks AS

SELECT achv.student_number
      ,achv.academic_year
      ,achv.reporting_term
      ,achv.[start_date] AS lit_term_start_date
      ,achv.end_date AS lit_term_end_date
      ,achv.achv_unique_id AS unique_id
      ,1 AS is_fp
      ,ate.test_date
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.gleq
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.met_goal
      ,ate.color
      ,ate.genre
      ,ate.fp_keylever
FROM gabby.lit.achieved_by_round_static achv
JOIN gabby.powerschool.cohort_identifiers_static co
  ON achv.student_number = co.student_number
 AND achv.academic_year = co.academic_year
 AND co.rn_year = 1
 AND co.region = 'KCNA'
JOIN gabby.lit.all_test_events_static ate
  ON achv.achv_unique_id = ate.unique_id
WHERE achv.achv_unique_id LIKE 'FPBAS%'
