CREATE OR ALTER VIEW
  renaissance.ar_individualized_goals_long AS
SELECT
  student_number,
  CAST(
    REPLACE(reporting_term, 'q_', 'AR') AS NVARCHAR(4)
  ) AS reporting_term,
  CAST(adjusted_goal AS INT) AS adjusted_goal
FROM
  (
    SELECT
      student_number,
      CAST(q_1 AS INT) AS q_1,
      CAST(q_2 AS INT) AS q_2,
      CAST(q_3 AS INT) AS q_3,
      CAST(q_4 AS INT) AS q_4,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number
        ORDER BY
          _row DESC
      ) AS rn
    FROM
      gabby.renaissance.ar_individualized_goals
    WHERE
      student_number IS NOT NULL
  ) AS sub UNPIVOT (
    adjusted_goal FOR reporting_term IN (q_1, q_2, q_3, q_4)
  ) u
WHERE
  rn = 1
