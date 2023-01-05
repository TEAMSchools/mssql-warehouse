CREATE OR ALTER VIEW
  tableau.map_untested_roster AS
WITH
  subjects AS (
    SELECT
      'Reading' AS measurement_scale
    UNION
    SELECT
      'Mathematics'
    UNION
    SELECT
      'Language Usage'
    UNION
    SELECT
      'Science - General Science'
  ),
  scaffold AS (
    SELECT
      co.student_number,
      co.lastfirst,
      co.region,
      co.reporting_schoolid AS schoolid,
      co.grade_level,
      co.team,
      co.academic_year,
      terms.alt_name AS term_name,
      terms.start_date AS term_start_date,
      subjects.measurement_scale
    FROM
      powerschool.cohort_identifiers_static AS co
      INNER JOIN reporting.reporting_terms AS terms ON (
        co.academic_year = terms.academic_year
        AND terms.identifier = 'MAP'
        AND terms.start_date <= CURRENT_TIMESTAMP
        AND terms._fivetran_deleted = 0
      )
      CROSS JOIN subjects
    WHERE
      co.rn_year = 1
      AND co.grade_level != 99
      AND co.enroll_status = 0
      AND co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  )
SELECT
  student_number,
  lastfirst,
  academic_year,
  term_name,
  region,
  schoolid,
  grade_level,
  team,
  measurement_scale,
  map_student_id,
  test_date,
  rit,
  percentile,
  lexile,
  base_term,
  base_rit,
  base_percentile,
  base_lexile,
  n_tests,
  COALESCE(test_date, term_start_date) AS tested_on,
  COALESCE(rit, base_rit) AS current_rit,
  COALESCE(percentile, base_percentile) AS current_percentile,
  COALESCE(lexile, base_lexile) AS current_lexile,
  CASE
    WHEN n_tests > 1 THEN 'Multiple test events'
    WHEN (
      term_name IN ('Winter', 'Spring')
      AND map_student_id IS NULL
    ) THEN 'Missing test'
    WHEN (
      term_name = 'Fall'
      AND map_student_id IS NULL
      AND base_term IS NULL
    ) THEN 'Missing test, No baseline'
    WHEN (
      term_name = 'Fall'
      AND map_student_id IS NULL
      AND base_term IS NOT NULL
    ) THEN 'Missing test, Has baseline'
    WHEN (
      term_name = 'Fall'
      AND map_student_id IS NOT NULL
      AND base_term IS NOT NULL
    ) THEN 'Tested, Has baseline'
  END AS test_audit
FROM
  (
    SELECT
      r.student_number,
      r.lastfirst,
      r.region,
      r.schoolid,
      r.grade_level,
      r.team,
      r.academic_year,
      r.measurement_scale,
      r.term_name,
      r.term_start_date,
      map.student_id AS map_student_id,
      map.test_start_date AS test_date,
      map.test_ritscore AS rit,
      map.percentile_2015_norms AS percentile,
      map.ritto_reading_score AS lexile,
      base.term_name AS base_term,
      base.test_ritscore AS base_rit,
      base.testpercentile AS base_percentile,
      base.lexile_score AS base_lexile,
      COUNT(map.student_id) OVER (
        PARTITION BY
          map.student_id,
          map.academic_year,
          map.term,
          map.measurement_scale
      ) AS n_tests
    FROM
      scaffold AS r
      LEFT JOIN nwea.assessment_result_identifiers AS map ON (
        r.student_number = map.student_id
        AND r.academic_year = map.academic_year
        AND r.measurement_scale = map.measurement_scale
        AND r.term_name = map.term
      )
      LEFT JOIN nwea.best_baseline AS base ON (
        r.student_number = base.student_number
        AND r.academic_year = base.academic_year
        AND r.measurement_scale = base.measurementscale
      )
  ) AS sub
