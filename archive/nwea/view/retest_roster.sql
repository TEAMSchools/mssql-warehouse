USE gabby GO
CREATE OR ALTER VIEW
  nwea.retest_roster AS
WITH
  map_long AS (
    SELECT
      sub.student_id,
      sub.academic_year,
      sub.term,
      sub.measurement_scale,
      sub.test_ritscore,
      sub.npr,
      sub.test_start_date,
      sub.test_duration_minutes,
      sub.lastfirst,
      sub.reporting_schoolid,
      sub.region,
      sub.grade_level,
      sub.student_testdurationminutes,
      sub.prev_academic_year,
      sub.prev_term,
      sub.prev_rit,
      sub.prev_npr,
      sub.next_academic_year,
      sub.next_term,
      sub.next_rit,
      sub.next_npr,
      sub.student_N,
      AVG(CAST(test_duration_minutes AS FLOAT)) OVER (
        PARTITION BY
          grade_level,
          measurement_scale
      ) AS global_mean_testdurationminutes,
      STDEV(CAST(test_duration_minutes AS FLOAT)) OVER (
        PARTITION BY
          grade_level,
          measurement_scale
      ) AS global_stdev_testdurationminutes,
      AVG(CAST(student_testdurationminutes AS FLOAT)) OVER (
        PARTITION BY
          student_id,
          measurement_scale
      ) AS student_mean_testdurationminutes,
      STDEV(CAST(student_testdurationminutes AS FLOAT)) OVER (
        PARTITION BY
          student_id,
          measurement_scale
      ) AS student_stdev_testdurationminutes,
      SUM(student_N) OVER (
        PARTITION BY
          sub.measurement_scale,
          sub.grade_level,
          sub.term,
          sub.prev_term
      ) AS global_prev_N,
      SUM(student_N) OVER (
        PARTITION BY
          sub.measurement_scale,
          sub.grade_level,
          sub.term,
          sub.next_term
      ) AS global_next_N
    FROM
      (
        SELECT
          m.student_id,
          m.academic_year,
          m.term,
          m.measurement_scale,
          m.test_ritscore,
          m.percentile_2015_norms AS npr,
          m.test_start_date,
          m.test_duration_minutes,
          co.lastfirst,
          co.region,
          co.reporting_schoolid,
          co.grade_level,
          CASE
            WHEN COUNT(m.student_id) OVER (
              PARTITION BY
                m.student_id,
                m.measurement_scale
            ) < 4 THEN NULL
            ELSE m.test_duration_minutes
          END AS student_testdurationminutes,
          LAG(m.academic_year, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS prev_academic_year,
          LAG(m.term, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS prev_term,
          LAG(m.test_ritscore, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS prev_rit,
          LAG(m.percentile_2015_norms, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS prev_npr,
          LEAD(m.academic_year, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS next_academic_year,
          LEAD(m.term, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS next_term,
          LEAD(m.test_ritscore, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS next_rit,
          LEAD(m.percentile_2015_norms, 1) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
            ORDER BY
              m.test_start_date ASC
          ) AS next_npr,
          COUNT(m.student_id) OVER (
            PARTITION BY
              m.student_id,
              m.measurement_scale
          ) AS student_N
        FROM
          gabby.nwea.assessment_result_identifiers m
          INNER JOIN gabby.powerschool.cohort_identifiers_static co ON m.student_id = co.student_number
          AND m.academic_year = co.academic_year
          AND co.rn_year = 1
        WHERE
          m.rn_term_subj = 1
      ) sub
  )
SELECT
  sub.student_number,
  sub.lastfirst,
  sub.region,
  sub.schoolid,
  sub.grade_level,
  sub.academic_year,
  sub.term,
  sub.measurement_scale,
  sub.test_ritscore,
  sub.npr,
  sub.test_start_date,
  sub.test_duration_minutes,
  sub.student_testdurationminutes,
  sub.prev_academic_year,
  sub.prev_term,
  sub.prev_rit,
  sub.prev_npr,
  sub.next_academic_year,
  sub.next_term,
  sub.next_rit,
  sub.next_npr,
  sub.student_n,
  sub.global_mean_testdurationminutes,
  sub.global_stdev_testdurationminutes,
  sub.student_mean_testdurationminutes,
  sub.student_stdev_testdurationminutes,
  sub.global_prev_n,
  sub.global_next_n,
  sub.prev_npr_change,
  sub.next_npr_change,
  sub.mean_prev_npr_change,
  sub.mean_next_npr_change,
  sub.stdev_prev_npr_change,
  sub.stdev_next_npr_change,
  sub.global_testdurationminutes_z,
  sub.student_testdurationminutes_z,
  sub.prev_npr_z,
  sub.next_npr_z,
  ISNULL(global_testdurationminutes_z, 0) + ISNULL(prev_npr_z, 0) + 2 * ISNULL(student_testdurationminutes_z, 0) + 2 * ISNULL(
    CASE
      WHEN prev_npr_z < 0
      AND next_npr_z < 0 THEN prev_npr_z + next_npr_z
      ELSE NULL
    END,
    0
  ) AS total_z
FROM
  (
    SELECT
      sub.student_id AS student_number,
      sub.lastfirst,
      sub.region,
      sub.schoolid,
      sub.grade_level,
      sub.academic_year,
      sub.term,
      sub.measurement_scale,
      sub.test_ritscore,
      sub.npr,
      sub.test_start_date,
      sub.test_duration_minutes,
      sub.student_TestDurationMinutes,
      sub.prev_academic_year,
      sub.prev_term,
      sub.prev_rit,
      sub.prev_npr,
      sub.next_academic_year,
      sub.next_term,
      sub.next_rit,
      sub.next_npr,
      sub.student_N,
      sub.global_mean_testdurationminutes,
      sub.global_stdev_testdurationminutes,
      sub.student_mean_testdurationminutes,
      sub.student_stdev_testdurationminutes,
      sub.global_prev_N,
      sub.global_next_N,
      sub.prev_npr_change,
      sub.next_npr_change,
      sub.mean_prev_npr_change,
      sub.mean_next_npr_change,
      sub.stdev_prev_npr_change,
      sub.stdev_next_npr_change,
      (
        student_testdurationminutes - global_mean_testdurationminutes
      ) / CASE
        WHEN global_stdev_testdurationminutes = 0 THEN NULL
        ELSE global_stdev_testdurationminutes
      END AS global_testdurationminutes_z,
      (
        student_testdurationminutes - student_mean_testdurationminutes
      ) / CASE
        WHEN student_stdev_testdurationminutes = 0 THEN NULL
        ELSE student_stdev_testdurationminutes
      END AS student_testdurationminutes_z,
      (prev_npr_change - mean_prev_npr_change) / CASE
        WHEN stdev_prev_npr_change = 0 THEN NULL
        ELSE stdev_prev_npr_change
      END AS prev_npr_z,
      -1 * (next_npr_change - mean_next_npr_change) / CASE
        WHEN stdev_next_npr_change = 0 THEN NULL
        ELSE stdev_next_npr_change
      END AS next_npr_z
    FROM
      (
        SELECT
          sub.student_id,
          sub.lastfirst,
          sub.region,
          sub.schoolid,
          sub.grade_level,
          sub.academic_year,
          sub.term,
          sub.measurement_scale,
          sub.test_ritscore,
          sub.npr,
          sub.test_start_date,
          sub.test_duration_minutes,
          sub.student_TestDurationMinutes,
          sub.prev_academic_year,
          sub.prev_term,
          sub.prev_rit,
          sub.prev_npr,
          sub.next_academic_year,
          sub.next_term,
          sub.next_rit,
          sub.next_npr,
          sub.student_N,
          sub.global_mean_testdurationminutes,
          sub.global_stdev_testdurationminutes,
          sub.student_mean_testdurationminutes,
          sub.student_stdev_testdurationminutes,
          sub.global_prev_N,
          sub.global_next_N,
          sub.prev_npr_change,
          sub.next_npr_change,
          AVG(prev_npr_change) OVER (
            PARTITION BY
              grade_level,
              measurement_scale,
              term,
              prev_term
          ) AS mean_prev_npr_change,
          STDEV(prev_npr_change) OVER (
            PARTITION BY
              grade_level,
              measurement_scale,
              term,
              prev_term
          ) AS stdev_prev_npr_change,
          AVG(next_npr_change) OVER (
            PARTITION BY
              grade_level,
              measurement_scale,
              term,
              next_term
          ) AS mean_next_npr_change,
          STDEV(next_npr_change) OVER (
            PARTITION BY
              grade_level,
              measurement_scale,
              term,
              next_term
          ) AS stdev_next_npr_change
        FROM
          (
            SELECT
              map_long.student_id,
              map_long.lastfirst,
              map_long.region,
              map_long.reporting_schoolid AS schoolid,
              map_long.grade_level,
              map_long.academic_year,
              map_long.term,
              map_long.measurement_scale,
              map_long.test_ritscore,
              map_long.npr,
              map_long.test_start_date,
              map_long.test_duration_minutes,
              map_long.student_testdurationminutes,
              map_long.prev_academic_year,
              map_long.prev_term,
              map_long.prev_rit,
              map_long.prev_npr,
              map_long.next_academic_year,
              map_long.next_term,
              map_long.next_rit,
              map_long.next_npr,
              map_long.student_n,
              map_long.global_mean_testdurationminutes,
              map_long.global_stdev_testdurationminutes,
              map_long.student_mean_testdurationminutes,
              map_long.student_stdev_testdurationminutes,
              map_long.global_prev_n,
              map_long.global_next_N,
              CASE
                WHEN map_long.global_prev_N < 100 THEN NULL
                WHEN map_long.academic_year - map_long.prev_academic_year < 1 THEN NULL /* previous NPR should be from at least 1 year ago -- this seems weird*/
                WHEN map_long.term = map_long.prev_term THEN NULL
                ELSE map_long.npr - map_long.prev_npr
              END AS prev_npr_change,
              CASE
                WHEN map_long.global_next_N < 100 THEN NULL
                WHEN map_long.next_academic_year - map_long.academic_year > 1 THEN NULL
                WHEN map_long.term = map_long.next_term THEN NULL
                ELSE map_long.next_npr - map_long.npr
              END AS next_npr_change
            FROM
              map_long
          ) sub
      ) sub
  ) sub
