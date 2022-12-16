CREATE OR ALTER VIEW
  tableau.graduation_requirements AS
WITH
  parcc AS (
    SELECT
      parcc.local_student_identifier,
      parcc.test_scale_score AS test_score,
      CONCAT('parcc_', LOWER(parcc.test_code))
    COLLATE Latin1_General_BIN AS test_type
    FROM
      gabby.parcc.summative_record_file_clean AS parcc
    WHERE
      parcc.test_code IN (
        'ELA09',
        'ELA10',
        'ELA11',
        'ALG01',
        'GEO01',
        'ALG02'
      )
  ),
  sat AS (
    SELECT
      u.hs_student_id,
      u.[value] AS test_score,
      CONCAT('sat_', u.field)
    COLLATE Latin1_General_BIN AS test_type
    FROM
      (
        SELECT
          sat.hs_student_id,
          CAST(sat.evidence_based_reading_writing AS INT) AS evidence_based_reading_writing,
          CAST(sat.math AS INT) AS math,
          CAST(sat.reading_test AS INT) AS reading_test,
          CAST(sat.math_test AS INT) AS math_test
        FROM
          gabby.naviance.sat_scores AS sat
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          evidence_based_reading_writing,
          math,
          reading_test,
          math_test
        )
      ) AS u
  ),
  act AS (
    SELECT
      st.score AS test_score,
      LEFT(st.score_type, LEN(st.score_type) - 2) AS test_type,
      ktc.student_number
    FROM
      gabby.alumni.standardized_test_long AS st
      INNER JOIN gabby.alumni.ktc_roster AS ktc ON st.contact_c = ktc.sf_contact_id
    WHERE
      st.test_type = 'ACT'
      AND st.score_type IN ('act_reading_c', 'act_math_c')
  ),
  all_tests AS (
    SELECT
      parcc.local_student_identifier,
      parcc.test_type,
      parcc.test_score
    FROM
      parcc
    UNION ALL
    SELECT
      sat.hs_student_id,
      sat.test_type,
      sat.test_score
    FROM
      sat
    UNION ALL
    SELECT
      act.student_number,
      act.test_type,
      act.test_score
    FROM
      act
  )
SELECT
  co.student_number,
  co.lastfirst,
  co.grade_level,
  co.cohort,
  co.enroll_status,
  co.iep_status,
  co.c_504_status,
  co.is_retained_year,
  co.is_retained_ever,
  co.school_abbreviation,
  a.test_type,
  a.test_score
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN all_tests AS a ON co.student_number = a.local_student_identifier
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.cohort BETWEEN (gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1) AND (gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 5)
