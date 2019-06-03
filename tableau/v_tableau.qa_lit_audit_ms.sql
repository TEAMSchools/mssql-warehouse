USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_lit_audit_ms AS

WITH fp_recent AS (
  SELECT fp.student_identifier
        ,fp.academic_year
        ,fp.test_round
        ,fp.reporting_term
        ,fp.round_num
        ,fp.schoolid
        ,fp.assessment_date
        ,fp.text_level
        ,fp.lvl_num
  FROM gabby.lit.fpodms_test_events fp
  WHERE fp.benchmark_level = 'Independent'
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

        ,rt.time_per_name AS reporting_term
        ,rt.alt_name AS test_round
        ,rt.[start_date] AS test_round_start_date

        ,g.fp_lvl_num AS goal_lvl_num

        ,fp.academic_year AS asssessment_academic_year
        ,fp.test_round AS asssessment_test_round
        ,fp.reporting_term AS asssessment_reporting_term
        ,fp.round_num AS assessment_round_number
        ,fp.assessment_date
        ,fp.text_level
        ,fp.lvl_num

        ,CASE
          WHEN fp.lvl_num >= 26 THEN 'Achieved Z'
          WHEN fp.lvl_num - g.fp_lvl_num > 0 THEN 'Above Target'
          WHEN fp.lvl_num - g.fp_lvl_num = 0 THEN 'Target'
          WHEN fp.lvl_num - g.fp_lvl_num = -1 THEN 'Approaching'
          WHEN fp.lvl_num - g.fp_lvl_num = -2 THEN 'Below'
          WHEN fp.lvl_num - g.fp_lvl_num < -2 THEN 'Far Below'
         END AS goal_status

        ,ROW_NUMBER() OVER(
           PARTITION BY co.student_number, co.academic_year, rt.time_per_name
             ORDER BY fp.assessment_date DESC, fp.lvl_num DESC) AS rn
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
  LEFT JOIN fp_recent fp
    ON co.student_number = fp.student_identifier
   AND rt.start_date > fp.assessment_date
  WHERE co.rn_year = 1
    AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND co.school_level = 'MS'
    AND co.grade_level != 99
 )

/* Q1 */
SELECT s.student_number
      ,s.lastfirst
      ,s.academic_year
      ,s.reporting_schoolid
      ,s.grade_level
      ,s.region
      ,s.entrydate
      ,s.year_in_network
      ,s.reporting_term
      ,s.test_round
      ,s.test_round_start_date
      ,s.goal_lvl_num
      ,s.asssessment_academic_year
      ,s.asssessment_test_round
      ,s.asssessment_reporting_term
      ,s.assessment_round_number
      ,s.assessment_date
      ,s.text_level
      ,s.lvl_num
      ,s.goal_status
      ,CASE
        WHEN s.lvl_num = 26 THEN 0 /* Achieved Z */
        WHEN s.year_in_network = 1 THEN 1 /* new to KNJ */
        WHEN s.assessment_date IS NULL THEN 1 /* missing all data */
        WHEN s.goal_status = 'Far Below' THEN 1 /* status */
        WHEN s.academic_year - s.asssessment_academic_year > 1 THEN 1 /* more than 2 rounds ago */
        WHEN s.asssessment_test_round NOT IN ('Q3', 'Q4', 'DR') THEN 1 /* more than 2 rounds ago */
        ELSE 0
       END AS audit_status
      ,CASE
        WHEN s.year_in_network = 1 THEN 'New to KIPP NJ'
        WHEN s.assessment_date IS NULL THEN 'No Assessment Data'
        WHEN s.goal_status = 'Far Below' THEN 'Far Below'
        WHEN s.academic_year - s.asssessment_academic_year > 1 THEN 'More Than 2 Rounds Since Last Test'
        WHEN s.asssessment_test_round NOT IN ('Q3', 'Q4', 'DR') THEN 'More Than 2 Rounds Since Last Test'
       END AS audit_reason
FROM scaffold s
WHERE s.rn = 1
  AND s.test_round = 'Q1'

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
      ,s.reporting_term
      ,s.test_round
      ,s.test_round_start_date
      ,s.goal_lvl_num
      ,s.asssessment_academic_year
      ,s.asssessment_test_round
      ,s.asssessment_reporting_term
      ,s.assessment_round_number
      ,s.assessment_date
      ,s.text_level
      ,s.lvl_num
      ,s.goal_status
      ,CASE
        WHEN s.lvl_num = 26 THEN 0 /* Achieved Z */
        WHEN s.entrydate >= s.test_round_start_date THEN 1 /* new to KNJ */
        WHEN s.assessment_date IS NULL THEN 1 /* missing all data */
        WHEN s.goal_status IN ('Below', 'Approaching') THEN 1 /* status */
        ELSE 0
       END AS audit_status
      ,CASE
        WHEN s.entrydate >= s.test_round_start_date THEN 'New to KIPP NJ'
        WHEN s.assessment_date IS NULL THEN  'No Assessment Data'
        WHEN s.goal_status IN ('Below', 'Approaching') THEN 'Below/Approaching'
       END AS audit_reason
FROM scaffold s
WHERE s.rn = 1
  AND s.test_round = 'Q2'

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
      ,s.reporting_term
      ,s.test_round
      ,s.test_round_start_date
      ,s.goal_lvl_num
      ,s.asssessment_academic_year
      ,s.asssessment_test_round
      ,s.asssessment_reporting_term
      ,s.assessment_round_number
      ,s.assessment_date
      ,s.text_level
      ,s.lvl_num
      ,s.goal_status
      ,CASE
        WHEN s.lvl_num = 26 THEN 0 /* Achieved Z */
        WHEN s.entrydate >= s.test_round_start_date THEN 1 /* new to KNJ */
        WHEN s.assessment_date IS NULL THEN 1 /* missing all data */
        WHEN s.goal_status IN ('Far Below', 'Below') THEN 1 /* status */
        ELSE 0
       END AS audit_status
      ,CASE
        WHEN s.entrydate >= s.test_round_start_date THEN 'New to KIPP NJ'
        WHEN s.assessment_date IS NULL THEN  'No Assessment Data'
        WHEN s.goal_status IN ('Far Below', 'Below') THEN 'Far Below/Below'
       END AS audit_reason
FROM scaffold s
WHERE s.rn = 1
  AND s.test_round = 'Q3'

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
      ,s.reporting_term
      ,s.test_round
      ,s.test_round_start_date
      ,s.goal_lvl_num
      ,s.asssessment_academic_year
      ,s.asssessment_test_round
      ,s.asssessment_reporting_term
      ,s.assessment_round_number
      ,s.assessment_date
      ,s.text_level
      ,s.lvl_num
      ,s.goal_status
      ,CASE
        WHEN s.lvl_num = 26 THEN 0 /* Achieved Z */
        WHEN s.entrydate >= s.test_round_start_date THEN 1 /* new to KNJ */
        WHEN s.assessment_date IS NULL THEN 1 /* missing all data */
        WHEN s.asssessment_test_round != 'Q3' THEN 1
        ELSE 0
       END AS audit_status
      ,CASE
        WHEN s.entrydate >= s.test_round_start_date THEN 'New to KIPP NJ'
        WHEN s.assessment_date IS NULL THEN  'No Assessment Data'
        WHEN s.academic_year != s.asssessment_academic_year THEN 'Not Tested in Q3'
        WHEN s.asssessment_test_round != 'Q3' THEN 'Not Tested in Q3'
       END AS audit_reason
FROM scaffold s
WHERE s.rn = 1
  AND s.test_round = 'Q4'