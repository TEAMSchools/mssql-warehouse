WITH
  measurementscales (measurementscale) AS (
    SELECT
      'Mathematics'
    UNION
    SELECT
      'Reading'
    UNION
    SELECT
      'Language Usage'
    UNION
    SELECT
      'Science - General Science'
  ),
  terms (term) AS (
    SELECT
      'Fall'
    UNION
    SELECT
      'Winter'
    UNION
    SELECT
      'Spring'
  ),
  grade_levels AS (
    SELECT
      n AS grade_level
    FROM
      gabby.utilities.row_generator
    WHERE
      (n BETWEEN 0 AND 12)
  ),
  scaffold AS (
    SELECT
      m.measurementscale,
      t.term,
      gr.grade_level,
      COALESCE(u.n, n.student_percentile) AS testpercentile,
      n.testritscore,
      ROW_NUMBER() OVER (
        PARTITION BY
          m.measurementscale,
          t.term,
          gr.grade_level,
          COALESCE(u.n, n.student_percentile)
        ORDER BY
          n.testritscore ASC
      ) AS rn
    FROM
      gabby.utilities.row_generator AS u
      CROSS JOIN measurementscales AS m
      CROSS JOIN terms AS t
      CROSS JOIN grade_levels AS gr
      LEFT OUTER JOIN gabby.nwea.percentile_norms AS n ON (
        u.n = n.student_percentile
        AND m.measurementscale = n.measurementscale
        AND t.term = n.term
        AND gr.grade_level = n.grade_level
        AND n.norms_year = 2015
      )
    WHERE
      (u.n BETWEEN 1 AND 99)
  ),
  norms_dense AS (
    SELECT
      measurementscale,
      term,
      grade_level,
      testpercentile,
      COALESCE(
        testritscore,
        testritscore_lag1,
        testritscore_lag2,
        testritscore_lag3,
        testritscore_lag4,
        testritscore_lag5
      ) AS testritscore
    FROM
      (
        SELECT
          measurementscale,
          term,
          grade_level,
          testpercentile,
          testritscore,
          LAG(testritscore, 1) OVER (
            PARTITION BY
              measurementscale,
              term,
              grade_level
            ORDER BY
              testpercentile ASC
          ) AS testritscore_lag1,
          LAG(testritscore, 2) OVER (
            PARTITION BY
              measurementscale,
              term,
              grade_level
            ORDER BY
              testpercentile ASC
          ) AS testritscore_lag2,
          LAG(testritscore, 3) OVER (
            PARTITION BY
              measurementscale,
              term,
              grade_level
            ORDER BY
              testpercentile ASC
          ) AS testritscore_lag3,
          LAG(testritscore, 4) OVER (
            PARTITION BY
              measurementscale,
              term,
              grade_level
            ORDER BY
              testpercentile ASC
          ) AS testritscore_lag4,
          LAG(testritscore, 5) OVER (
            PARTITION BY
              measurementscale,
              term,
              grade_level
            ORDER BY
              testpercentile ASC
          ) AS testritscore_lag5
        FROM
          scaffold
        WHERE
          rn = 1
      ) AS sub
  )
SELECT
  *
FROM
  norms_dense
