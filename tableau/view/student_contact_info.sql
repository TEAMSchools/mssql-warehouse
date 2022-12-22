CREATE OR ALTER VIEW
  tableau.student_contact_info AS
SELECT
  student_number,
  newark_enrollment_number,
  state_studentnumber,
  lastfirst,
  schoolid,
  school_name,
  grade_level,
  team,
  advisor_name,
  entrydate,
  boy_status,
  dob,
  gender,
  lunchstatus,
  lunch_balance,
  home_phone,
  mother,
  mother_cell,
  father,
  father_cell,
  guardianemail,
  street,
  city,
  [state],
  zip,
  first_name,
  last_name,
  student_web_id,
  student_web_password,
  student_web_id + '.fam' AS family_web_id,
  student_web_password AS family_web_password,
  NULL AS release_1_name,
  NULL AS release_1_phone,
  NULL AS release_2_name,
  NULL AS release_2_phone,
  NULL AS release_3_name,
  NULL AS release_3_phone,
  NULL AS release_4_name,
  NULL AS release_4_phone,
  NULL AS release_5_name,
  NULL AS release_5_phone
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  enroll_status = 0
  AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND rn_year = 1
