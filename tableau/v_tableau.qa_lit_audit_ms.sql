USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_lit_audit_ms AS

WITH fp_long AS (
  SELECT fp.student_number student_identifier
        ,fp.unique_id
        ,fp.academic_year AS assessment_academic_year
        ,fp.test_round AS assessment_test_round
        ,CASE 
          WHEN fp.status IN ('Did Not Achieve', 'DNA - Hard') THEN 'Did Not Achieve'
          ELSE fp.status
         END AS benchmark_level
        ,fp.test_date AS assessment_date
        ,fp.read_lvl AS text_level
        ,fp.lvl_num
        ,fp.genre

        ,co.schoolid

        ,ROW_NUMBER() OVER(
           PARTITION BY fp.student_number, fp.[status], fp.academic_year, fp.test_round
             ORDER BY fp.test_date DESC, fp.lvl_num DESC) AS rn
  FROM gabby.lit.all_test_events_static fp
  JOIN gabby.powerschool.cohort_identifiers_static co
    ON fp.student_number = co.student_number
   AND fp.academic_year = co.academic_year
   AND co.rn_year = 1
 )

,fp_recent AS (
  SELECT rt.academic_year
        ,rt.alt_name AS test_round
        ,rt.[start_date]
        
        ,fp.student_identifier
        ,fp.schoolid
        ,fp.unique_id
        ,fp.assessment_academic_year
        ,fp.assessment_test_round
        ,fp.benchmark_level
        ,fp.assessment_date
        ,fp.text_level
        ,fp.lvl_num
        ,fp.genre
        ,MAX(fp.lvl_num) OVER(PARTITION BY fp.student_identifier) AS max_lvl_num

        ,ROW_NUMBER() OVER(
           PARTITION BY rt.academic_year, rt.alt_name, fp.student_identifier, fp.benchmark_level
             ORDER BY fp.assessment_date DESC, fp.lvl_num DESC) AS rn
  FROM gabby.reporting.reporting_terms rt
  JOIN fp_long fp
    ON rt.schoolid = fp.schoolid
   AND rt.[start_date] > fp.assessment_date
  WHERE rt.identifier = 'LIT'
    AND rt._fivetran_deleted = 0
 )

,scaffold AS (
  SELECT co.student_number
        ,co.lastfirst
        ,co.academic_year
        ,co.reporting_schoolid
        ,co.grade_level
        ,co.region
        ,co.entrydate
        ,co.year_in_network

        ,rt.alt_name AS test_round
        ,rt.[start_date] AS test_round_start_date

        ,g.fp_lvl_num AS goal_lvl_num

        ,ind.text_level AS independent_level
        ,ind.max_lvl_num
        ,CASE
          WHEN ind.lvl_num >= 26 THEN 'Achieved Z'
          WHEN ind.lvl_num - g.fp_lvl_num > 0 THEN 'Above Target'
          WHEN ind.lvl_num - g.fp_lvl_num = 0 THEN 'Target'
          WHEN ind.lvl_num - g.fp_lvl_num = -1 THEN 'Approaching'
          WHEN ind.lvl_num - g.fp_lvl_num = -2 THEN 'Below'
          WHEN ind.lvl_num - g.fp_lvl_num < -2 THEN 'Far Below'
         END AS goal_status

        ,COALESCE(ins.assessment_academic_year, hard.assessment_academic_year) AS instructional_academic_year
        ,COALESCE(ins.assessment_test_round, hard.assessment_test_round) AS instructional_test_round
        ,COALESCE(ins.assessment_date, hard.assessment_date) AS instructional_assessment_date
        ,COALESCE(ins.text_level, hard.text_level) AS instructional_level
        ,COALESCE(ins.genre, hard.genre) AS instructional_genre
  FROM gabby.powerschool.cohort_identifiers_static co
  JOIN gabby.reporting.reporting_terms rt
    ON co.schoolid = rt.schoolid
   AND co.academic_year = rt.academic_year
   AND rt.identifier = 'LIT'
   AND rt._fivetran_deleted = 0
  JOIN gabby.lit.network_goals g
    ON co.grade_level = g.grade_level
   AND rt.alt_name = g.test_round
   AND g.norms_year = 2018
  LEFT JOIN fp_recent ind
    ON co.student_number = ind.student_identifier
   AND rt.academic_year = ind.academic_year
   AND rt.alt_name = ind.test_round
   AND ind.rn = 1
   AND ind.benchmark_level = 'Achieved'
  LEFT JOIN fp_recent ins
    ON co.student_number = ins.student_identifier
   AND rt.academic_year = ins.academic_year
   AND rt.alt_name = ins.test_round
   AND ins.rn = 1
   AND ins.benchmark_level = 'Did Not Achieve'
  LEFT JOIN fp_recent hard
    ON co.student_number = hard.student_identifier
   AND rt.academic_year = hard.academic_year
   AND rt.alt_name = hard.test_round
   AND hard.rn = 1
   AND hard.benchmark_level = 'DNA - Hard'
  WHERE co.rn_year = 1
    AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND co.school_level = 'MS'
 )

,audits_long AS (
  /* DR */
  SELECT s.student_number
        ,s.lastfirst
        ,s.academic_year
        ,s.reporting_schoolid
        ,s.grade_level
        ,s.region
        ,s.entrydate
        ,s.year_in_network
        ,s.test_round
        ,s.test_round_start_date
        ,s.goal_lvl_num
        ,s.independent_level
        ,s.goal_status
        ,s.instructional_academic_year
        ,s.instructional_test_round
        ,s.instructional_assessment_date
        ,s.instructional_level
        ,s.instructional_genre
        ,CASE
          WHEN s.max_lvl_num = 26 THEN 0 /* Achieved Z */
          WHEN s.independent_level = 'Z' THEN 0 /* Achieved Z */
          WHEN s.year_in_network = 1 THEN 1 /* new to KNJ */
          WHEN s.instructional_assessment_date IS NULL THEN 1 /* missing all data */
          WHEN s.academic_year - s.instructional_academic_year > 1 THEN 1 /* more than 2 rounds ago */
          WHEN s.instructional_test_round NOT IN ('Q3', 'Q4') THEN 1 /* more than 2 rounds ago */
          ELSE 0
         END AS audit_status
        ,CASE
          WHEN s.year_in_network = 1 THEN 'New to KIPP NJ'
          WHEN s.instructional_assessment_date IS NULL THEN 'No Instructional Level'
          WHEN s.academic_year - s.instructional_academic_year > 1 THEN 'More Than 2 Rounds Since Last Test'
          WHEN s.instructional_test_round NOT IN ('Q3', 'Q4') THEN 'More Than 2 Rounds Since Last Test'
         END AS audit_reason
  FROM scaffold s
  WHERE s.test_round = 'DR'

  UNION ALL

  /* Q1 */
  SELECT s.student_number
        ,s.lastfirst
        ,s.academic_year
        ,s.reporting_schoolid
        ,s.grade_level
        ,s.region
        ,s.entrydate
        ,s.year_in_network
        ,s.test_round
        ,s.test_round_start_date
        ,s.goal_lvl_num
        ,s.independent_level
        ,s.goal_status
        ,s.instructional_academic_year
        ,s.instructional_test_round
        ,s.instructional_assessment_date
        ,s.instructional_level
        ,s.instructional_genre
        ,CASE
          WHEN s.max_lvl_num = 26 THEN 0 /* Achieved Z */
          WHEN s.independent_level = 'Z' THEN 0 /* Achieved Z */
          WHEN s.year_in_network = 1 THEN 1 /* new to KNJ */
          WHEN s.instructional_assessment_date IS NULL THEN 1 /* missing all data */
          WHEN s.goal_status = 'Far Below' THEN 1 /* status */
          WHEN s.academic_year - s.instructional_academic_year > 1 THEN 1 /* more than 2 rounds ago */
          WHEN s.instructional_test_round NOT IN ('Q3', 'Q4', 'DR') THEN 1 /* more than 2 rounds ago */
          ELSE 0
         END AS audit_status
        ,CASE
          WHEN s.year_in_network = 1 THEN 'New to KIPP NJ'
          WHEN s.instructional_assessment_date IS NULL THEN 'No Instructional Level'
          WHEN s.goal_status = 'Far Below' THEN 'Far Below'
          WHEN s.academic_year - s.instructional_academic_year > 1 THEN 'More Than 3 Rounds Since Last Test'
          WHEN s.instructional_test_round NOT IN ('Q3', 'Q4', 'DR') THEN 'More Than 3 Rounds Since Last Test'
         END AS audit_reason
  FROM scaffold s
  WHERE s.test_round = 'Q1'

  UNION ALL

  /* Q2 */
  SELECT s.student_number
        ,s.lastfirst
        ,s.academic_year
        ,s.reporting_schoolid
        ,s.grade_level
        ,s.region
        ,s.entrydate
        ,s.year_in_network
        ,s.test_round
        ,s.test_round_start_date
        ,s.goal_lvl_num
        ,s.independent_level
        ,s.goal_status
        ,s.instructional_academic_year
        ,s.instructional_test_round
        ,s.instructional_assessment_date
        ,s.instructional_level
        ,s.instructional_genre
        ,CASE
          WHEN s.max_lvl_num = 26 THEN 0 /* Achieved Z */
          WHEN s.independent_level = 'Z' THEN 0 /* Achieved Z */
          WHEN s.entrydate >= s.test_round_start_date THEN 1 /* new to KNJ */
          WHEN s.instructional_assessment_date IS NULL THEN 1 /* missing all data */
          WHEN s.goal_status IN ('Below', 'Approaching') THEN 1 /* status */
          ELSE 0
         END AS audit_status
        ,CASE
          WHEN s.entrydate >= s.test_round_start_date THEN 'New to KIPP NJ'
          WHEN s.instructional_assessment_date IS NULL THEN  'No Instructional Level'
          WHEN s.goal_status IN ('Below', 'Approaching') THEN 'Below/Approaching'
         END AS audit_reason
  FROM scaffold s
  WHERE s.test_round = 'Q2'

  UNION ALL

  /* Q3 */
  SELECT s.student_number
        ,s.lastfirst
        ,s.academic_year
        ,s.reporting_schoolid
        ,s.grade_level
        ,s.region
        ,s.entrydate
        ,s.year_in_network
        ,s.test_round
        ,s.test_round_start_date
        ,s.goal_lvl_num
        ,s.independent_level
        ,s.goal_status
        ,s.instructional_academic_year
        ,s.instructional_test_round
        ,s.instructional_assessment_date
        ,s.instructional_level
        ,s.instructional_genre
        ,CASE
          WHEN s.max_lvl_num = 26 THEN 0 /* Achieved Z */
          WHEN s.independent_level = 'Z' THEN 0 /* Achieved Z */
          WHEN s.entrydate >= s.test_round_start_date THEN 1 /* new to KNJ */
          WHEN s.instructional_assessment_date IS NULL THEN 1 /* missing all data */
          WHEN s.goal_status IN ('Far Below', 'Below') THEN 1 /* status */
          ELSE 0
         END AS audit_status
        ,CASE
          WHEN s.entrydate >= s.test_round_start_date THEN 'New to KIPP NJ'
          WHEN s.instructional_assessment_date IS NULL THEN  'No Instructional Level'
          WHEN s.goal_status IN ('Far Below', 'Below') THEN 'Far Below/Below'
         END AS audit_reason
  FROM scaffold s
  WHERE s.test_round = 'Q3'

  UNION ALL

  /* Q4 */
  SELECT s.student_number
        ,s.lastfirst
        ,s.academic_year
        ,s.reporting_schoolid
        ,s.grade_level
        ,s.region
        ,s.entrydate
        ,s.year_in_network
        ,s.test_round
        ,s.test_round_start_date
        ,s.goal_lvl_num
        ,s.independent_level
        ,s.goal_status
        ,s.instructional_academic_year
        ,s.instructional_test_round
        ,s.instructional_assessment_date
        ,s.instructional_level
        ,s.instructional_genre
        ,CASE
          WHEN s.max_lvl_num = 26 THEN 0 /* Achieved Z */
          WHEN s.independent_level = 'Z' THEN 0 /* Achieved Z */
          WHEN s.entrydate >= s.test_round_start_date THEN 1 /* new to KNJ */
          WHEN s.instructional_assessment_date IS NULL THEN 1 /* missing all data */
          WHEN s.academic_year != s.instructional_academic_year THEN 1 /* not tested in Q3 */
          WHEN s.instructional_test_round != 'Q3' THEN 1 /* not tested in Q3 */
          ELSE 0
         END AS audit_status
        ,CASE
          WHEN s.entrydate >= s.test_round_start_date THEN 'New to KIPP NJ'
          WHEN s.instructional_assessment_date IS NULL THEN  'No Instructional Level'
          WHEN s.academic_year != s.instructional_academic_year THEN 'Not Tested in Q3'
          WHEN s.instructional_test_round != 'Q3' THEN 'Not Tested in Q3'
         END AS audit_reason
  FROM scaffold s
  WHERE s.test_round = 'Q4'
 )

SELECT al.student_number
      ,al.lastfirst
      ,al.academic_year
      ,al.reporting_schoolid
      ,al.grade_level
      ,al.region
      ,al.entrydate
      ,al.year_in_network
      ,al.test_round
      ,al.test_round_start_date
      ,al.goal_lvl_num
      ,al.independent_level
      ,al.goal_status
      ,al.instructional_academic_year
      ,al.instructional_test_round
      ,al.instructional_assessment_date
      ,al.instructional_level
      ,al.instructional_genre
      ,al.audit_status
      ,al.audit_reason

      ,COALESCE(ins.unique_id, hard.unique_id) AS verify_unique_id
FROM audits_long al
LEFT JOIN fp_long ins
  ON al.student_number = ins.student_identifier
 AND al.academic_year = ins.assessment_academic_year
 AND al.test_round = ins.assessment_test_round
 AND ins.benchmark_level = 'Did Not Achieve'
 AND ins.rn = 1
LEFT JOIN fp_long hard
  ON al.student_number = hard.student_identifier
 AND al.academic_year = hard.assessment_academic_year
 AND al.test_round = hard.assessment_test_round
 AND hard.benchmark_level = 'DNA - Hard'
 AND hard.rn = 1