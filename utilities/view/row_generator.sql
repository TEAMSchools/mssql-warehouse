CREATE OR ALTER VIEW
  utilities.row_generator AS
WITH
  t0 (i) AS (
    SELECT
      0
    UNION ALL
    SELECT
      0
  ),
  t1 (i) AS (
    SELECT
      a.i
    FROM
      t0 AS a
      CROSS JOIN t0
  ),
  t2 (i) AS (
    SELECT
      a.i
    FROM
      t1 AS a
      CROSS JOIN t1
  ),
  t3 (i) AS (
    SELECT
      a.i
    FROM
      t2 AS a
      CROSS JOIN t2
  ),
  t4 (i) AS (
    SELECT
      a.i
    FROM
      t3 AS a
      CROSS JOIN t3
  ),
  t5 (i) AS (
    SELECT
      a.i
    FROM
      t4 AS a
      CROSS JOIN t4
  )
SELECT
  0 AS n
UNION ALL
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      t5.i
  ) AS n
FROM
  t5
