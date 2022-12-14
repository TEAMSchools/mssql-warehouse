USE gabby GO
CREATE OR ALTER VIEW
  naviance.sat_2_scores_clean AS
SELECT
  studentid AS naviance_studentid,
  hs_student_id AS student_number,
  test_code,
  test_name,
  test_date,
  score,
  gabby.utilities.DATE_TO_SY (test_date) AS academic_year
FROM
  (
    SELECT
      CAST(studentid AS INT) AS studentid,
      CAST(hs_student_id AS INT) AS hs_student_id,
      CAST(test_code AS VARCHAR(5)) AS test_code,
      CAST(test_name AS VARCHAR(25)) AS test_name,
      CAST(score AS INT) AS score,
      CASE
        WHEN test_date = '0000-00-00' THEN NULL
        WHEN RIGHT(test_date, 2) = '00' THEN DATEFROMPARTS(
          LEFT(test_date, 4),
          SUBSTRING(test_date, 6, 2),
          01
        )
        ELSE CAST(test_date AS DATE)
      END AS test_date
    FROM
      gabby.naviance.sat_2_scores
  ) sub
