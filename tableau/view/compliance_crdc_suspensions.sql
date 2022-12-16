CREATE OR ALTER VIEW
  tableau.compliance_crdc_suspensions AS
SELECT
  co.student_number,
  co.state_studentnumber,
  co.lastfirst,
  co.academic_year,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.enroll_status,
  co.gender,
  co.ethnicity,
  co.iep_status AS spedlep,
  co.specialed_classification AS sped_code,
  co.c_504_status AS status_504,
  co.lep_status,
  co.year_in_network,
  att.streak_id,
  att.att_code,
  att.streak_start,
  att.streak_end,
  att.streak_length_membership
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.powerschool.attendance_streak AS att ON co.studentid = att.studentid
  AND co.db_name = att.db_name
  AND att.att_code IN ('OSS', 'ISS')
