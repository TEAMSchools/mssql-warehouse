WITH
  fsa_scores AS (
    SELECT
      fleid,
      academic_year,
      [ELA] AS fsa_ela,
      [Math] AS fsa_math
    FROM
      (
        SELECT
          fs.fleid,
          '20' + LEFT(fs.school_year, 2) AS academic_year,
          CASE
            WHEN fs._file LIKE '%ELA%' THEN 'ELA'
            WHEN fs._file LIKE '%MATH%' THEN 'Math'
          END AS [subject],
          CASE
            WHEN fs.performance_level IS NOT NULL THEN CONCAT(
              'Level ',
              fs.performance_level,
              ' (',
              fs.scale_score,
              ')'
            )
          END AS fsa_score
        FROM
          kippmiami.fsa.student_scores AS fs
        WHERE
          (
            fs._file LIKE '%ELA%'
            OR fs._file LIKE '%MATH%'
          )
          AND fs.scale_score IS NOT NULL
      ) AS sub PIVOT (
        MAX(fsa_score) FOR [subject] IN ([ELA], [Math])
      ) AS p
  ),
  fast_scores AS (
    SELECT
      fleid,
      academic_year,
      [pm1_reading],
      [pm1_math],
      [pm2_reading],
      [pm2_math]
    FROM
      (
        SELECT
          fa.fleid,
          fa.academic_year,
          LOWER(
            LEFT(fa.pm_round, 3) + '_' + fa.fast_subject
          ) AS fast_round,
          fa.achievement_level + ' (' + fa.scale_score + ')' AS fast_score
        FROM
          kippmiami.fast.student_data_long AS fa
      ) AS sub PIVOT (
        MAX(fast_score) FOR fast_round IN (
          [pm1_reading],
          [pm1_math],
          [pm2_reading],
          [pm2_math]
        )
      ) AS p
  )
SELECT
  co.student_number,
  co.state_studentnumber AS mdcps_id,
  suf.fleid,
  co.lastfirst,
  co.school_abbreviation AS school,
  co.grade_level,
  co.team,
  fs.fsa_ela,
  fs.fsa_math,
  fa.pm1_reading,
  fa.pm2_reading,
  fa.pm1_math,
  fa.pm2_math
FROM
  kippmiami.powerschool.cohort_identifiers_static AS co
  LEFT JOIN kippmiami.powerschool.u_studentsuserfields AS suf ON (
    co.students_dcid = suf.studentsdcid
  )
  LEFT JOIN fsa_scores AS fs ON (
    suf.fleid = fs.fleid
    AND co.academic_year = fs.academic_year + 1
  )
  LEFT JOIN fast_scores AS fa ON (
    suf.fleid = fa.fleid
    AND co.academic_year = fa.academic_year
  )
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND (co.grade_level BETWEEN 4 AND 5)
ORDER BY
  co.school_abbreviation,
  co.grade_level,
  co.lastfirst
