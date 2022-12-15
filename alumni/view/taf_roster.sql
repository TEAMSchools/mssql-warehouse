USE gabby GO
CREATE OR ALTER VIEW
  alumni.taf_roster AS
WITH
  enrollments AS (
    SELECT
      CAST(enr.student_c AS VARCHAR(25)) AS salesforce_contact_id,
      CAST(enr.type_c AS VARCHAR(25)) AS enrollment_type,
      CAST(enr.status_c AS VARCHAR(25)) AS enrollment_status,
      CAST(enr.name AS VARCHAR(125)) AS enrollment_name,
      enr.start_date_c,
      ROW_NUMBER() OVER (
        PARTITION BY
          enr.student_c
        ORDER BY
          start_date_c DESC
      ) AS rn
    FROM
      gabby.alumni.enrollment_c AS enr
    WHERE
      enr.is_deleted = 0
  )
SELECT
  r.student_number,
  r.studentid,
  r.lastfirst,
  r.exit_schoolid AS schoolid,
  r.exit_school_name AS school_name,
  r.exit_date AS exitdate,
  r.exit_db_name AS DB_NAME,
  r.current_grade_level_projection AS approx_grade_level,
  r.ktc_cohort AS cohort,
  r.expected_hs_graduation_date,
  r.counselor_name AS ktc_counselor,
  r.sf_home_phone,
  r.sf_mobile_phone,
  r.sf_other_phone,
  r.sf_email,
  s.first_name,
  s.last_name,
  s.dob,
  s.guardianemail AS ps_email,
  1 AS is_grad,
  enr.enrollment_type,
  enr.enrollment_name,
  enr.enrollment_status,
  CAST(s.home_phone AS VARCHAR(125)) AS ps_home_phone,
  CAST(s.mother AS VARCHAR(125)) AS ps_mother,
  CAST(s.father AS VARCHAR(125)) AS ps_father,
  CAST(s.doctor_name AS VARCHAR(125)) AS ps_doctor_name,
  CAST(s.doctor_phone AS VARCHAR(125)) AS ps_doctor_phone,
  CAST(s.emerg_contact_1 AS VARCHAR(125)) AS ps_emerg_contact_1,
  CAST(s.emerg_phone_1 AS VARCHAR(125)) AS ps_emerg_phone_1,
  CAST(s.emerg_contact_2 AS VARCHAR(125)) AS ps_emerg_contact_2,
  CAST(s.emerg_phone_2 AS VARCHAR(125)) AS ps_emerg_phone_2,
  CAST(scf.mother_home_phone AS VARCHAR(125)) AS ps_mother_home,
  CAST(scf.father_home_phone AS VARCHAR(125)) AS ps_father_home,
  CAST(scf.emerg_1_rel AS VARCHAR(125)) AS ps_emerg_1_rel,
  CAST(scf.emerg_2_rel AS VARCHAR(125)) AS ps_emerg_2_rel,
  CAST(scf.emerg_contact_3 AS VARCHAR(125)) AS ps_emerg_contact_3,
  CAST(scf.emerg_3_rel AS VARCHAR(125)) AS ps_emerg_3_rel,
  CAST(scf.emerg_3_phone AS VARCHAR(125)) AS ps_emerg_3_phone,
  CAST(suf.mother_cell AS VARCHAR(125)) AS ps_mother_cell,
  CAST(suf.parent_motherdayphone AS VARCHAR(125)) AS ps_mother_day,
  CAST(suf.father_cell AS VARCHAR(125)) AS ps_father_cell,
  CAST(suf.parent_fatherdayphone AS VARCHAR(125)) AS ps_father_day,
  CAST(suf.emerg_4_name AS VARCHAR(125)) AS ps_emerg_4_name,
  CAST(suf.emerg_4_rel AS VARCHAR(125)) AS ps_emerg_4_rel,
  CAST(suf.emerg_4_phone AS VARCHAR(125)) AS ps_emerg_4_phone,
  CAST(suf.emerg_5_name AS VARCHAR(125)) AS ps_emerg_5_name,
  CAST(suf.emerg_5_rel AS VARCHAR(125)) AS ps_emerg_5_rel,
  CAST(suf.emerg_5_phone AS VARCHAR(125)) AS ps_emerg_5_phone,
  CAST(suf.release_1_name AS VARCHAR(125)) AS ps_release_1_name,
  CAST(suf.release_1_phone AS VARCHAR(125)) AS ps_release_1_phone,
  CAST(suf.release_1_relation AS VARCHAR(125)) AS ps_release_1_relation,
  CAST(suf.release_2_name AS VARCHAR(125)) AS ps_release_2_name,
  CAST(suf.release_2_phone AS VARCHAR(125)) AS ps_release_2_phone,
  CAST(suf.release_2_relation AS VARCHAR(125)) AS ps_release_2_relation,
  CAST(suf.release_3_name AS VARCHAR(125)) AS ps_release_3_name,
  CAST(suf.release_3_phone AS VARCHAR(125)) AS ps_release_3_phone,
  CAST(suf.release_3_relation AS VARCHAR(125)) AS ps_release_3_relation,
  CAST(suf.release_4_name AS VARCHAR(125)) AS ps_release_4_name,
  CAST(suf.release_4_phone AS VARCHAR(125)) AS ps_release_4_phone,
  CAST(suf.release_4_relation AS VARCHAR(125)) AS ps_release_4_relation,
  CAST(suf.release_5_name AS VARCHAR(125)) AS ps_release_5_name,
  CAST(suf.release_5_phone AS VARCHAR(125)) AS ps_release_5_phone,
  CAST(suf.release_5_relation AS VARCHAR(125)) AS ps_release_5_relation
FROM
  gabby.alumni.ktc_roster AS r
  LEFT JOIN enrollments AS enr ON r.sf_contact_id = enr.salesforce_contact_id
  AND enr.rn = 1
  LEFT JOIN gabby.powerschool.students AS s ON r.student_number = s.student_number
  AND r.exit_db_name = s.db_name
  LEFT JOIN gabby.powerschool.u_studentsuserfields AS suf ON s.dcid = suf.studentsdcid
  AND s.db_name = suf.db_name
  LEFT JOIN gabby.powerschool.studentcorefields AS scf ON s.dcid = scf.studentsdcid
  AND s.db_name = scf.db_name
WHERE
  r.ktc_status IN ('TAF', 'TAFHS')
