CREATE OR ALTER VIEW
  extracts.renlearn_students AS
SELECT
  student_number AS id,
  student_number,
  first_name,
  last_name,
  middle_name,
  gender,
  grade_level,
  ethnicity,
  dob,
  enroll_status,
  exitcode,
  exitdate,
  state_studentnumber,
  student_web_id + '@teamstudents.org' AS student_email
FROM
  gabby.powerschool.cohort_identifiers_static AS co
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND (
    co.school_level = 'MS'
    OR co.schoolid = 73256
  ) /* ad hoc rule for Seek */
