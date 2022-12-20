CREATE OR ALTER VIEW
  extracts.gsheets_student_logins AS
SELECT
  student_number,
  lastfirst,
  grade_level,
  team,
  school_name,
  CONVERT(VARCHAR, entrydate, 101) AS entrydate,
  student_web_id,
  student_web_password,
  student_web_id + '@teamstudents.org' AS student_email,
  region
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND rn_year = 1
  AND enroll_status = 0
