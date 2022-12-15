USE gabby GO
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
      0
    FROM
      t0 AS a,
      t0 b
  ),
  t2 (i) AS (
    SELECT
      0
    FROM
      t1 AS a,
      t1 b
  ),
  t3 (i) AS (
    SELECT
      0
    FROM
      t2 AS a,
      t2 b
  ),
  t4 (i) AS (
    SELECT
      0
    FROM
      t3 AS a,
      t3 b
  ),
  t5 (i) AS (
    SELECT
      0
    FROM
      t4 AS a,
      t4 b
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
