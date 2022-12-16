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
      N AS grade_level
    FROM
      gabby.utilities.row_generator
    WITH
      (NOLOCK)
    WHERE
      N (BETWEEN 0 AND 12)
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
    WITH
      (NOLOCK)
      CROSS JOIN measurementscales AS m
      CROSS JOIN terms AS t
      CROSS JOIN grade_levels AS gr
      LEFT OUTER JOIN gabby.nwea.percentile_norms AS n
    WITH
      (NOLOCK) ON u.n = n.student_percentile
      AND m.measurementscale = n.measurementscale
      AND t.term = n.term
      AND gr.grade_level = n.grade_level
      AND n.norms_year = 2015
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
          s1.measurementscale,
          s1.term,
          s1.grade_level,
          s1.testpercentile,
          s1.testritscore,
          LAG(s1.testritscore, 1) OVER (
            PARTITION BY
              s1.measurementscale,
              s1.term,
              s1.grade_level
            ORDER BY
              s1.testpercentile ASC
          ) AS testritscore_lag1,
          LAG(s1.testritscore, 2) OVER (
            PARTITION BY
              s1.measurementscale,
              s1.term,
              s1.grade_level
            ORDER BY
              s1.testpercentile ASC
          ) AS testritscore_lag2,
          LAG(s1.testritscore, 3) OVER (
            PARTITION BY
              s1.measurementscale,
              s1.term,
              s1.grade_level
            ORDER BY
              s1.testpercentile ASC
          ) AS testritscore_lag3,
          LAG(s1.testritscore, 4) OVER (
            PARTITION BY
              s1.measurementscale,
              s1.term,
              s1.grade_level
            ORDER BY
              s1.testpercentile ASC
          ) AS testritscore_lag4,
          LAG(s1.testritscore, 5) OVER (
            PARTITION BY
              s1.measurementscale,
              s1.term,
              s1.grade_level
            ORDER BY
              s1.testpercentile ASC
          ) AS testritscore_lag5
        FROM
          scaffold AS s1
        WHERE
          rn = 1
      ) AS sub
  )
SELECT
  *
FROM
  norms_dense
