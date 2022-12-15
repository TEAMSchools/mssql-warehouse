USE gabby GO
CREATE OR ALTER VIEW
  tableau.student_contact_info AS
SELECT
  co.student_number,
  co.newark_enrollment_number,
  co.state_studentnumber,
  co.lastfirst,
  co.schoolid,
  co.school_name,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.entrydate,
  co.boy_status,
  co.dob,
  co.gender,
  co.lunchstatus,
  co.lunch_balance,
  co.home_phone,
  co.mother,
  co.mother_cell,
  co.father,
  co.father_cell,
  co.guardianemail,
  co.street,
  co.city,
  co.[state],
  co.zip,
  co.first_name,
  co.last_name,
  co.student_web_id,
  co.student_web_password,
  co.student_web_id + '.fam' AS family_web_id,
  co.student_web_password AS family_web_password,
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
  gabby.powerschool.cohort_identifiers_static AS co
WHERE
  co.enroll_status = 0
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
