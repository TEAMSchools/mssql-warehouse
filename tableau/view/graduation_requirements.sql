CREATE OR ALTER VIEW
  tableau.graduation_requirements AS
WITH
  parcc AS (
    SELECT
      local_student_identifier,
      test_scale_score AS test_score,
      (
        CONCAT('parcc_', LOWER(test_code))
        COLLATE LATIN1_GENERAL_BIN
      ) AS test_type
    FROM
      gabby.parcc.summative_record_file_clean
    WHERE
      test_code IN (
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
      hs_student_id,
      [value] AS test_score,
      (
        CONCAT('sat_', field)
        COLLATE LATIN1_GENERAL_BIN
      ) AS test_type
    FROM
      (
        SELECT
          hs_student_id,
          CAST(
            evidence_based_reading_writing AS INT
          ) AS evidence_based_reading_writing,
          CAST(math AS INT) AS math,
          CAST(reading_test AS INT) AS reading_test,
          CAST(math_test AS INT) AS math_test
        FROM
          gabby.naviance.sat_scores
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
      LEFT(
        st.score_type,
        LEN(st.score_type) - 2
      ) AS test_type,
      ktc.student_number
    FROM
      gabby.alumni.standardized_test_long AS st
      INNER JOIN gabby.alumni.ktc_roster AS ktc ON (st.contact_c = ktc.sf_contact_id)
    WHERE
      st.test_type = 'ACT'
      AND st.score_type IN ('act_reading_c', 'act_math_c')
  ),
  all_tests AS (
    SELECT
      local_student_identifier,
      test_type,
      test_score
    FROM
      parcc
    UNION ALL
    SELECT
      hs_student_id,
      test_type,
      test_score
    FROM
      sat
    UNION ALL
    SELECT
      student_number,
      test_type,
      test_score
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
  LEFT JOIN all_tests AS a ON (
    co.student_number = a.local_student_identifier
  )
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND (
    co.cohort BETWEEN (
      gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1
    ) AND (
      gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 5
    )
  )
