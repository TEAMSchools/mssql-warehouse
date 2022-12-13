USE gabby GO
CREATE OR ALTER VIEW
  extracts.gsheets_student_logins AS
SELECT
  co.student_number,
  co.lastfirst,
  co.grade_level,
  co.team,
  co.school_name,
  CAST(co.entrydate AS VARCHAR) AS entrydate,
  co.student_web_id,
  co.student_web_password,
  co.student_web_id + '@teamstudents.org' AS student_email,
  co.region
FROM
  gabby.powerschool.cohort_identifiers_static co
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.enroll_status = 0
