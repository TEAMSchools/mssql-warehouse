SELECT
  CONCAT(
    c.student_web_id,
    '@teamstudents.org'
  ) AS student_identifier,
  c.cohort,
  c.lastfirst,
  c.grade_level,
  c.region,
  c.reporting_school_name,
  c.academic_year
FROM
  gabby.powerschool.cohort_identifiers_static AS c
WHERE
  c.enroll_status = 0
  AND c.rn_year = 1
  AND c.academic_year = 2022
UNION ALL
SELECT
  c.student_web_id AS student_identifier,
  c.cohort,
  c.lastfirst,
  c.grade_level,
  c.region,
  c.reporting_school_name,
  c.academic_year
FROM
  gabby.powerschool.cohort_identifiers_static AS c
WHERE
  c.enroll_status = 0
  AND c.rn_year = 1
  AND c.academic_year = 2022
UNION ALL
SELECT
  c.student_number AS student_identifier c.cohort,
  c.lastfirst,
  c.grade_level,
  c.region,
  c.reporting_school_name,
  c.academic_year
FROM
  gabby.powerschool.cohort_identifiers_static AS c
WHERE
  c.enroll_status = 0
  AND c.rn_year = 1
  AND c.academic_year = 2022
