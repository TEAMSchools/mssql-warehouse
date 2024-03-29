CREATE OR ALTER VIEW
  naviance.sat_scores_clean AS
WITH
  sat_union AS (
    SELECT
      CAST(student_id AS INT) AS student_id,
      CAST(hs_student_id AS INT) AS hs_student_id,
      CAST(
        evidence_based_reading_writing AS FLOAT
      ) AS evidence_based_reading_writing,
      CAST(math AS FLOAT) AS math,
      CAST(total AS FLOAT) AS total,
      CAST(reading_test AS FLOAT) AS reading_test,
      CAST(writing_test AS FLOAT) AS writing_test,
      CAST(math_test AS FLOAT) AS math_test,
      NULL AS writing,
      NULL AS essay_subscore,
      CAST(math_test AS FLOAT) + CAST(reading_test AS FLOAT) AS mc_subscore,
      DATEFROMPARTS(
        RIGHT(test_date, 4),
        LEFT(
          test_date,
          CHARINDEX('/', test_date) - 1
        ),
        1
      ) AS test_date,
      1600 AS sat_scale,
      0 AS is_old_sat
    FROM
      naviance.sat_scores
    UNION ALL
    SELECT
      CAST(studentid AS INT) AS student_id,
      CAST(hs_student_id AS INT) AS hs_student_id,
      CAST(verbal AS FLOAT) AS evidence_based_reading_writing,
      CAST(math AS FLOAT) AS math,
      CAST(total AS FLOAT) AS total,
      NULL AS reading_test,
      CAST(essay_subscore AS FLOAT) AS writing_test,
      NULL AS math_test,
      CAST(writing AS FLOAT) AS writing,
      CAST(essay_subscore AS FLOAT) AS essay_subscore,
      CAST(mc_subscore AS FLOAT) AS mc_subscore,
      CASE
        WHEN test_date = '0000-00-00' THEN NULL
        WHEN RIGHT(test_date, 2) = '00' THEN DATEFROMPARTS(
          LEFT(test_date, 4),
          SUBSTRING(test_date, 6, 2),
          01
        )
        ELSE CAST(test_date AS DATE)
      END AS test_date,
      2400 AS sat_scale,
      1 AS is_old_sat
    FROM
      naviance.sat_scores_before_mar_2016
  ),
  sat_clean AS (
    SELECT
      student_id AS nav_studentid,
      hs_student_id AS student_number,
      sat_scale,
      is_old_sat,
      test_date,
      CASE
        WHEN test_date > CAST(CURRENT_TIMESTAMP AS DATE) THEN 1
      END AS test_date_flag,
      CASE
        WHEN (
          evidence_based_reading_writing BETWEEN 200 AND 800
        ) THEN evidence_based_reading_writing
      END AS verbal,
      CASE
        WHEN (math BETWEEN 200 AND 800) THEN math
      END AS math,
      CASE
        WHEN (writing BETWEEN 200 AND 800) THEN writing
      END AS writing,
      CASE
        WHEN essay_subscore = 0 THEN NULL
        ELSE essay_subscore
      END AS essay_subscore,
      CASE
        WHEN mc_subscore = 0 THEN NULL
        ELSE mc_subscore
      END AS mc_subscore,
      evidence_based_reading_writing + math AS math_verbal_total,
      CASE
        WHEN total < 200 THEN NULL
        ELSE total
      END AS all_tests_total,
      CASE
        WHEN ISNULL(
          CASE
            WHEN (
              evidence_based_reading_writing BETWEEN 200 AND 800
            ) THEN evidence_based_reading_writing
          END,
          0
        ) + ISNULL(
          CASE
            WHEN (math BETWEEN 200 AND 800) THEN math
          END,
          0
        ) + ISNULL(
          CASE
            WHEN (writing BETWEEN 200 AND 800) THEN writing
          END,
          0
        ) != total THEN 1
        WHEN (total NOT BETWEEN 400 AND 2400) THEN 1
      END AS total_flag
    FROM
      sat_union
  )
SELECT
  nav_studentid,
  student_number,
  test_date,
  sat_scale,
  is_old_sat,
  verbal,
  math,
  writing,
  essay_subscore,
  mc_subscore,
  math_verbal_total,
  all_tests_total,
  test_date_flag,
  total_flag,
  utilities.DATE_TO_SY (test_date) AS academic_year,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number
    ORDER BY
      all_tests_total DESC
  ) AS rn_highest,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      test_date
    ORDER BY
      test_date
  ) AS dupe_audit,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number
    ORDER BY
      test_date ASC
  ) AS n_attempt
FROM
  sat_clean
