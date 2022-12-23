CREATE OR ALTER VIEW
  naviance.act_scores_clean AS
SELECT
  naviance_studentid,
  student_number,
  test_type,
  academic_year,
  test_date,
  composite,
  english,
  math,
  reading,
  science,
  writing,
  ela,
  writing_sub,
  comb_eng_write,
  stem,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number
    ORDER BY
      composite DESC
  ) AS rn_highest,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number
    ORDER BY
      test_date ASC
  ) AS n_attempt,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      academic_year
    ORDER BY
      test_date ASC
  ) AS n_attempt_year
FROM
  (
    SELECT
      naviance_studentid,
      student_number,
      test_type,
      composite,
      english,
      math,
      reading,
      science,
      writing,
      writing_sub,
      comb_eng_write,
      ela,
      stem,
      gabby.utilities.DATE_TO_SY (test_date) AS academic_year,
      CASE
        WHEN test_date <= CAST(CURRENT_TIMESTAMP AS DATE) THEN test_date
      END AS test_date,
      CASE
        WHEN composite != ROUND(
          (
            /* trunk-ignore(sqlfluff/L016) */
            ISNULL(english, 0) + ISNULL(math, 0) + ISNULL(reading, 0) + ISNULL(science, 0)
          ) / 4,
          0
        ) THEN 1
      END AS composite_flag,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number,
          test_date
        ORDER BY
          composite DESC
      ) AS dupe_audit
    FROM
      (
        SELECT
          CAST(studentid AS INT) AS naviance_studentid,
          CAST(hs_student_id AS INT) AS student_number,
          'ACT' AS test_type,
          CASE
            WHEN test_date = '0000-00-00' THEN NULL
            WHEN RIGHT(test_date, 2) = '00' THEN DATEFROMPARTS(
              LEFT(test_date, 4),
              SUBSTRING(test_date, 6, 2),
              01
            )
            ELSE CAST(test_date AS DATE)
          END AS test_date,
          CAST(
            CASE
              WHEN (composite BETWEEN 1 AND 36) THEN composite
            END AS INT
          ) AS composite,
          CAST(
            CASE
              WHEN (english BETWEEN 1 AND 36) THEN english
            END AS INT
          ) AS english,
          CAST(
            CASE
              WHEN (math BETWEEN 1 AND 36) THEN math
            END AS INT
          ) AS math,
          CAST(
            CASE
              WHEN (reading BETWEEN 1 AND 36) THEN reading
            END AS INT
          ) AS reading,
          CAST(
            CASE
              WHEN (science BETWEEN 1 AND 36) THEN science
            END AS INT
          ) AS science,
          CAST(
            CASE
              WHEN (writing BETWEEN 1 AND 36) THEN writing
            END AS INT
          ) AS writing,
          CAST(
            CASE
              WHEN ela = 0 THEN NULL
              ELSE ela
            END AS INT
          ) AS ela,
          CAST(
            CASE
              WHEN (writing_sub BETWEEN 2 AND 12) THEN writing_sub
            END AS INT
          ) AS writing_sub,
          CAST(
            CASE
              WHEN comb_eng_write = 0 THEN NULL
              ELSE comb_eng_write
            END AS INT
          ) AS comb_eng_write,
          CAST(
            CASE
              WHEN stem = 0 THEN NULL
              ELSE stem
            END AS INT
          ) AS stem
        FROM
          gabby.naviance.act_scores
        WHERE
          test_type IN ('ACT (Legacy)', 'ACT')
      ) AS sub
  ) AS sub
