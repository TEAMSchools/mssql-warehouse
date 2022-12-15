USE gabby GO
CREATE OR ALTER VIEW
  lit.steptool_test_events AS
SELECT
  sub.unique_id,
  sub.student_number,
  sub.academic_year,
  sub.test_date,
  sub.read_lvl,
  sub.lvl_num,
  sub.[status],
  sub.ps_testid,
  sub.color,
  sub.notes,
  sub.recorder,
  sub.gleq,
  sub.gleq_lvl_num,
  co.studentid,
  co.lastfirst,
  co.schoolid,
  co.grade_level,
  CAST(dt.alt_name AS VARCHAR(5)) AS test_round,
  CAST(RIGHT(dt.time_per_name, 1) AS INT) AS round_num
FROM
  (
    SELECT
      CAST(
        CONCAT(
          'UC',
          gabby.utilities.DATE_TO_SY (step.[date]),
          step.[_line]
        ) AS VARCHAR(25)
      ) AS unique_id,
      CAST(CAST(step.student_id AS FLOAT) AS INT) AS student_number,
      gabby.utilities.DATE_TO_SY (CAST(step.[date] AS DATE)) AS academic_year,
      CAST(step.[date] AS DATE) AS test_date,
      CASE
        WHEN step.step = 0 THEN 'Pre'
        ELSE CAST(step.step AS VARCHAR(5))
      END AS read_lvl,
      step.step AS lvl_num,
      CASE
        WHEN step.passed = 1 THEN 'Achieved'
        WHEN step.passed = 0 THEN 'Did Not Achieve'
      END AS [status],
      CASE
        WHEN CAST(step.step AS INT) = 0 THEN 3280
        WHEN CAST(step.step AS INT) = 1 THEN 3281
        WHEN CAST(step.step AS INT) = 2 THEN 3282
        WHEN CAST(step.step AS INT) = 3 THEN 3380
        WHEN CAST(step.step AS INT) = 4 THEN 3397
        WHEN CAST(step.step AS INT) = 5 THEN 3411
        WHEN CAST(step.step AS INT) = 6 THEN 3425
        WHEN CAST(step.step AS INT) = 7 THEN 3441
        WHEN CAST(step.step AS INT) = 8 THEN 3458
        WHEN CAST(step.step AS INT) = 9 THEN 3474
        WHEN CAST(step.step AS INT) = 10 THEN 3493
        WHEN CAST(step.step AS INT) = 11 THEN 3511
        WHEN CAST(step.step AS INT) = 12 THEN 3527
      END AS ps_testid,
      CAST(step.book AS VARCHAR(25)) AS color,
      CAST(step.notes AS VARCHAR(1000)) AS notes,
      CAST(step.recorder AS VARCHAR(125)) AS recorder,
      gleq.gleq,
      CAST(gleq.lvl_num AS INT) AS gleq_lvl_num
    FROM
      gabby.steptool.all_steps AS step
      INNER JOIN gabby.lit.gleq ON step.step = gleq.lvl_num
      AND gleq.testid <> 3273
    UNION ALL
    /* ACHIEVED PRE DNA */
    SELECT
      CAST(
        CONCAT(
          'UCDNA',
          gabby.utilities.DATE_TO_SY (step.[date]),
          step.[_line]
        ) AS VARCHAR(25)
      ) AS unique_id,
      CAST(CAST(step.student_id AS FLOAT) AS INT) AS student_number,
      gabby.utilities.DATE_TO_SY (CAST(step.[date] AS DATE)) AS academic_year,
      CAST(step.[date] AS DATE) AS test_date,
      'Pre DNA' AS read_lvl,
      -1 AS lvl_num,
      'Achieved' AS [status],
      3280 AS ps_testid,
      CAST(step.book AS VARCHAR(25)) AS color,
      CAST(step.notes AS VARCHAR(1000)) AS notes,
      CAST(step.recorder AS VARCHAR(125)) AS recorder,
      -1 AS gleq,
      -1 AS gleq_lvl_num
    FROM
      gabby.steptool.all_steps AS step
    WHERE
      step.step = 0
      AND step.passed = 0
  ) sub
  INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON sub.student_number = co.student_number
  AND sub.academic_year = co.academic_year
  AND co.rn_year = 1
  INNER JOIN gabby.reporting.reporting_terms AS dt ON co.schoolid = dt.schoolid
  AND (
    sub.test_date BETWEEN dt.[start_date] AND dt.end_date
  )
  AND dt.identifier = 'LIT'
  AND dt._fivetran_deleted = 0
