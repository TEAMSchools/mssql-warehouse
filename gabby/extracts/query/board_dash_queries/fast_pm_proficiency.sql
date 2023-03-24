SELECT
  co.academic_year,
  co.region,
  co.school_abbreviation,
  co.student_number,
  co.iep_status,
  LEFT(fs.pm_round, 3) AS pm_round,
  fs.fast_subject AS [subject],
  fs.fast_test AS test_code,
  RIGHT(fs.achievement_level, 1) AS achievement_level,
  CASE
    WHEN RIGHT(fs.achievement_level, 1) >= 3 THEN 1
    WHEN RIGHT(fs.achievement_level, 1) < 3 THEN 0
  END AS is_proficient
FROM
  kippmiami.fast.student_data_long AS fs
  LEFT JOIN kippmiami.powerschool.u_studentsuserfields AS suf ON (fs.fleid = suf.fleid)
  LEFT JOIN kippmiami.powerschool.cohort_identifiers_static AS co ON (
    suf.studentsdcid = co.students_dcid
    AND co.academic_year = fs.academic_year
    AND co.rn_year = 1
  )
WHERE
  fs.achievement_level LIKE 'Level%'
