CREATE OR ALTER VIEW
  tableau.act_prep_scores AS
WITH
  real_tests AS (
    SELECT
      stl.contact_c,
      stl.date_c AS test_date,
      stl.score AS scale_score,
      CONCAT(
        LEFT(
          DATENAME(MONTH, stl.date_c),
          3
        ),
        ' ''',
        RIGHT(
          DATEPART(YEAR, stl.date_c),
          2
        )
      ) AS administration_round,
      ktc.student_number,
      ROW_NUMBER() OVER (
        PARTITION BY
          stl.contact_c
        ORDER BY
          stl.score DESC
      ) AS rn_highest
    FROM
      gabby.alumni.standardized_test_long AS stl
      INNER JOIN gabby.alumni.ktc_roster AS ktc ON stl.contact_c = ktc.sf_contact_id
    WHERE
      stl.score_type = 'act_composite_c'
  ),
  ms_grad AS (
    SELECT
      student_number,
      ms_attended
    FROM
      (
        SELECT
          student_number,
          school_name AS ms_attended,
          ROW_NUMBER() OVER (
            PARTITION BY
              student_number
            ORDER BY
              exitdate DESC
          ) AS rn
        FROM
          gabby.powerschool.cohort_identifiers_static
        WHERE
          school_level = 'MS'
      ) AS sub
    WHERE
      rn = 1
  )
SELECT
  co.academic_year,
  co.student_number,
  co.lastfirst,
  co.schoolid,
  co.grade_level,
  co.cohort,
  co.iep_status,
  co.enroll_status,
  co.advisor_name,
  co.region,
  'PREP' AS ACT_type,
  act.assessment_id,
  act.assessment_title,
  act.administration_round,
  act.administered_at AS test_date,
  act.subject_area,
  act.overall_percent_correct,
  act.overall_number_correct,
  act.number_of_questions,
  act.scale_score,
  act.prev_scale_score,
  act.pretest_scale_score,
  act.growth_from_pretest,
  act.overall_performance_band,
  act.standard_strand,
  act.standard_code,
  act.standard_description,
  act.standard_percent_correct,
  act.standard_mastered,
  act.rn_dupe AS rn_assessment /* 1 row per student, per test (overall) */,
  ms.ms_attended,
  1 AS rn_assessment_standard /* 1 row per student, per test (by standard) */,
  NULL AS rn_highest
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN gabby.act.test_prep_scores AS act ON co.student_number = act.student_number
  AND co.academic_year = act.academic_year
  LEFT JOIN ms_grad AS ms ON co.student_number = ms.student_number
WHERE
  co.rn_year = 1
  AND co.school_level = 'HS'
  AND co.academic_year >= 2015 /* 1st year with ACT prep */
UNION ALL
SELECT
  co.academic_year,
  co.student_number,
  co.lastfirst,
  co.schoolid,
  co.grade_level,
  co.cohort,
  co.iep_status,
  co.enroll_status,
  co.advisor_name,
  co.region,
  'REAL' AS ACT_type,
  NULL AS assessment_id,
  NULL AS assessment_title,
  CAST(co.cohort AS VARCHAR) AS administration_round,
  r.test_date,
  'Composite' AS subject_area,
  NULL AS overall_percent_correct,
  NULL AS overall_number_correct,
  NULL AS number_of_questions,
  r.scale_score,
  NULL AS prev_scale_score,
  NULL AS pretest_scale_score,
  NULL AS growth_from_pretest,
  NULL AS overall_performance_band,
  NULL AS standard_strand,
  NULL AS standard_code,
  NULL AS standard_description,
  NULL AS standard_percent_correct,
  NULL AS standard_mastered,
  1 AS rn_assessment,
  ms.ms_attended,
  1 AS rn_assessment_standard,
  r.rn_highest
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN real_tests AS r ON co.student_number = r.student_number
  AND (
    r.test_date BETWEEN co.entrydate AND co.exitdate
  )
  LEFT JOIN ms_grad AS ms ON co.student_number = ms.student_number
WHERE
  co.rn_year = 1
