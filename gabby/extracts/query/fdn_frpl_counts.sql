SELECT
  co.school_abbreviation,
  co.grade_level,
  co.lunchstatus,
  COUNT(co.student_number) AS student_count
FROM
  powerschool.cohort_identifiers_static AS co
  LEFT JOIN powerschool.schools AS sch ON co.schoolid = sch.school_number
  AND co.[db_name] = sch.[db_name]
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.is_enrolled_oct01 = 1
  AND co.db_name = 'kippmiami'
  AND co.lunchstatus != 'P'
GROUP BY
  co.school_abbreviation,
  co.grade_level,
  co.lunchstatus
ORDER BY
  co.school_abbreviation,
  co.grade_level,
  co.lunchstatus DESC
  