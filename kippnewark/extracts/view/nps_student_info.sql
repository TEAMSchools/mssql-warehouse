CREATE OR ALTER VIEW
  extracts.nps_student_info AS
SELECT
  co.student_number,
  co.state_studentnumber,
  CASE
    WHEN co.grade_level = 0 THEN 'K'
    ELSE CAST(co.grade_level AS VARCHAR)
  END AS grade_level,
  CAST(co.entrydate AS VARCHAR) AS entrydate,
  co.entrycode,
  co.exitcode,
  co.exitdate,
  CAST(co.dob AS VARCHAR) AS dob,
  co.gender,
  co.street,
  co.city,
  co.[state],
  co.zip,
  co.first_name,
  co.last_name,
  co.iep_status,
  co.lep_status,
  co.c_504_status,
  co.ethnicity /* need fed ethnicity */,
  co.students_dcid,
  co.specialed_classification,
  scw.contact_1_phone_primary AS home_phone /* confirm with pedro */,
  scw.contact_1_phone_primary AS mother_cell,
  scw.contact_2_phone_primary AS father_cell,
  scw.contact_1_name AS mother,
  scw.contact_2_name AS father,
  COALESCE(
    scw.contact_1_email_current,
    scw.contact_2_email_current
  ) AS guardianemail,
  s.fedethnicity
FROM
  powerschool.cohort_identifiers_static AS co
  LEFT JOIN powerschool.u_studentsuserfields AS suf ON (
    co.students_dcid = suf.studentsdcid
  )
  LEFT JOIN powerschool.studentcorefields AS scf ON (
    co.students_dcid = scf.studentsdcid
  )
  LEFT JOIN powerschool.student_contacts_wide_static AS scw ON (
    co.student_number = scw.student_number
  )
  LEFT JOIN powerschool.students AS s ON (
    co.student_number = s.student_number
  )
WHERE
  co.enroll_status IN (0, -1)
  AND co.rn_all = 1
