CREATE OR ALTER VIEW
  extracts.gsheets_student_roster AS
SELECT
  studentid,
  student_number,
  lastfirst,
  schoolid,
  school_name,
  grade_level,
  team,
  iep_status,
  state_studentnumber,
  region,
  reporting_schoolid,
  boy_status,
  enroll_status,
  advisor_name,
  student_web_id + '@teamstudents.org' AS student_email,
  is_pathways AS is_self_contained,
  ethnicity,
  lep_status
FROM
  powerschool.cohort_identifiers_static
WHERE
  academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND rn_year = 1
  AND grade_level != 99
