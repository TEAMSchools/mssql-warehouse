SELECT
  co.academic_year,
  co.region,
  co.school_abbreviation,
  co.student_number,
  co.iep_status,
  CASE
    WHEN sr.[subject] LIKE 'English%' THEN 'ELA'
    ELSE sr.[subject]
  END AS [subject],
  sr.test_code,
  sr.test_performance_level AS achievement_level,
  CASE
    WHEN sr.test_performance_level >= 4 THEN 1
    WHEN sr.test_performance_level < 4 THEN 0
  END AS is_proficient,
  CASE
    WHEN sr.test_performance_level <= 2 THEN 'Not Proficient (1-2)'
    WHEN sr.test_performance_level = 3 THEN 'Bubble (3)'
    WHEN sr.test_performance_level >= 4 THEN 'Proficient (4-5)'
  END AS proficiency_bands
FROM
  gabby.parcc.summative_record_file_clean AS sr
  LEFT JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
    co.student_number = sr.local_student_identifier
    OR co.state_studentnumber = sr.state_student_identifier
  )
  AND co.academic_year = sr.academic_year
  AND co.rn_year = 1
WHERE
  co.academic_year IN (2018, 2021)
  AND (
    sr.[subject] LIKE 'English%'
    OR sr.[subject] = 'Mathematics'
  )
