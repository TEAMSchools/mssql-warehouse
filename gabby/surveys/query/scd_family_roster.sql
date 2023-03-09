SELECT
  CONCAT(
    student_web_id,
    '@teamstudents.org'
  ) AS student_identifier,
  cohort,
  lastfirst,
  grade_level,
  region,
  reporting_school_name,
  academic_year
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  enroll_status = 0
  AND rn_year = 1
  AND academic_year = 2022
UNION ALL
SELECT
  student_web_id AS student_identifier,
  cohort,
  lastfirst,
  grade_level,
  region,
  reporting_school_name,
  academic_year
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  enroll_status = 0
  AND rn_year = 1
  AND academic_year = 2022
UNION ALL
SELECT
  student_number AS student_identifier,
  cohort,
  lastfirst,
  grade_level,
  region,
  reporting_school_name,
  academic_year
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  enroll_status = 0
  AND rn_year = 1
  AND academic_year = 2022
