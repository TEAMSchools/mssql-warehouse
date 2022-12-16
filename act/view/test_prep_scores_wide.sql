CREATE OR ALTER VIEW
  act.test_prep_scores_wide AS
SELECT
  student_number,
  academic_year,
  administration_round,
  english,
  mathematics,
  reading,
  science,
  composite,
  CASE
    WHEN composite >= 22 THEN 1.0
    ELSE 0.0
  END AS is_22,
  CASE
    WHEN composite >= 25 THEN 1.0
    ELSE 0.0
  END AS is_25,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      academic_year
    ORDER BY
      time_per_name DESC
  ) AS rn_curr
FROM
  (
    SELECT
      student_number,
      academic_year,
      administration_round,
      time_per_name,
      subject_area,
      scale_score
    FROM
      gabby.act.test_prep_scores
    WHERE
      rn_dupe = 1
  ) AS sub PIVOT (
    MAX(scale_score) FOR subject_area IN (
      english,
      mathematics,
      reading,
      science,
      composite
    )
  ) AS p
