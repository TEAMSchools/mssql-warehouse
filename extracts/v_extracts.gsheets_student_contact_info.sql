USE gabby GO
CREATE OR ALTER VIEW
  extracts.gsheets_student_contact_info AS
SELECT
  co.student_number,
  CASE
    WHEN co.region = 'KMS' THEN suf.fleid
    ELSE co.newark_enrollment_number
  END AS newark_enrollment_number,
  co.state_studentnumber,
  co.lastfirst,
  co.schoolid,
  co.school_name,
  CASE
    WHEN co.grade_level = 0 THEN 'K'
    ELSE CAST(co.grade_level AS VARCHAR(2))
  END AS grade_level,
  co.team,
  co.advisor_name,
  co.entrydate,
  co.boy_status,
  co.dob,
  co.gender,
  co.lunchstatus,
  CASE
    WHEN co.lunch_app_status IS NULL THEN 'N'
    WHEN co.lunch_app_status = 'No Application' THEN 'N'
    WHEN co.lunch_app_status LIKE 'Prior%' THEN 'N'
    ELSE 'Y'
  END AS lunch_app_status,
  CAST(co.lunch_balance AS MONEY) AS lunch_balance,
  co.home_phone,
  scw.contact_1_phone_primary AS mother_cell,
  scw.contact_2_phone_primary AS father_cell,
  scw.contact_1_name AS mother,
  scw.contact_2_name AS father,
  CONCAT(scw.pickup_1_name, ' | ', scw.pickup_1_phone_mobile) AS release_1,
  CONCAT(scw.pickup_2_name, ' | ', scw.pickup_2_phone_mobile) AS release_2,
  CONCAT(scw.pickup_3_name, ' | ', scw.pickup_3_phone_mobile) AS release_3,
  NULL AS release_4,
  NULL AS release_5,
  COALESCE(scw.contact_1_email_current, scw.contact_2_email_current) AS guardianemail,
  CONCAT(co.street, ', ', co.city, ', ', co.[state], ' ', co.zip) AS [address],
  co.first_name,
  co.last_name,
  co.student_web_id,
  co.student_web_password,
  co.student_web_id + '.fam' AS family_web_id,
  co.student_web_password AS family_web_password,
  suf.media_release,
  co.region,
  co.iep_status,
  co.lep_status,
  co.c_504_status,
  CASE
    WHEN scf.homeless_code IN ('Y1', 'Y2') THEN 1
  END AS is_homeless,
  suf.infosnap_opt_in,
  co.city,
  co.is_pathways AS is_selfcontained,
  suf.infosnap_id
FROM
  gabby.powerschool.cohort_identifiers_static co
  LEFT JOIN gabby.powerschool.u_studentsuserfields suf ON co.students_dcid = suf.studentsdcid
  AND co.[db_name] = suf.[db_name]
  LEFT JOIN gabby.powerschool.studentcorefields scf ON co.students_dcid = scf.studentsdcid
  AND co.[db_name] = scf.[db_name]
  LEFT JOIN gabby.powerschool.student_contacts_wide_static scw ON co.student_number = scw.student_number
  AND co.[db_name] = scw.[db_name]
WHERE
  co.enroll_status IN (0, -1)
  AND co.rn_all = 1
