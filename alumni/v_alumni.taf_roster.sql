USE gabby
GO

CREATE OR ALTER VIEW alumni.taf_roster AS 

WITH enrollments AS (
  SELECT CONVERT(VARCHAR(25),enr.student_c) AS salesforce_contact_id
        ,CONVERT(VARCHAR(25),enr.type_c) AS enrollment_type
        ,CONVERT(VARCHAR(25),enr.status_c) AS enrollment_status
        ,CONVERT(VARCHAR(125),enr.name) AS enrollment_name
        ,enr.start_date_c
        ,ROW_NUMBER() OVER(
           PARTITION BY enr.student_c
             ORDER BY start_date_c DESC) AS rn
  FROM gabby.alumni.enrollment_c enr
  WHERE enr.is_deleted = 0
 )

SELECT r.student_number
      ,r.studentid
      ,r.lastfirst
      ,r.exit_schoolid AS schoolid
      ,r.exit_school_name AS school_name
      ,r.exit_date AS exitdate
      ,r.exit_db_name AS db_name
      ,r.current_grade_level_projection AS approx_grade_level
      ,r.ktc_cohort AS cohort
      ,r.expected_hs_graduation_date
      ,r.counselor_name AS ktc_counselor
      ,r.sf_home_phone
      ,r.sf_mobile_phone
      ,r.sf_other_phone
      ,r.sf_email
      
      ,s.first_name
      ,s.last_name
      ,s.dob
      ,s.guardianemail AS ps_email
      ,1 AS is_grad

      ,enr.enrollment_type
      ,enr.enrollment_name
      ,enr.enrollment_status
      
      ,CONVERT(VARCHAR(125),s.home_phone) AS ps_home_phone
      ,CONVERT(VARCHAR(125),s.mother) AS ps_mother
      ,CONVERT(VARCHAR(125),s.father) AS ps_father
      ,CONVERT(VARCHAR(125),s.doctor_name) AS ps_doctor_name
      ,CONVERT(VARCHAR(125),s.doctor_phone) AS ps_doctor_phone
      ,CONVERT(VARCHAR(125),s.emerg_contact_1) AS ps_emerg_contact_1
      ,CONVERT(VARCHAR(125),s.emerg_phone_1) AS ps_emerg_phone_1
      ,CONVERT(VARCHAR(125),s.emerg_contact_2) AS ps_emerg_contact_2
      ,CONVERT(VARCHAR(125),s.emerg_phone_2) AS ps_emerg_phone_2

      ,CONVERT(VARCHAR(125),scf.mother_home_phone) AS ps_mother_home
      ,CONVERT(VARCHAR(125),scf.father_home_phone) AS ps_father_home
      ,CONVERT(VARCHAR(125),scf.emerg_1_rel) AS ps_emerg_1_rel
      ,CONVERT(VARCHAR(125),scf.emerg_2_rel) AS ps_emerg_2_rel
      ,CONVERT(VARCHAR(125),scf.emerg_contact_3) AS ps_emerg_contact_3
      ,CONVERT(VARCHAR(125),scf.emerg_3_rel) AS ps_emerg_3_rel
      ,CONVERT(VARCHAR(125),scf.emerg_3_phone) AS ps_emerg_3_phone
            
      ,CONVERT(VARCHAR(125),suf.mother_cell) AS ps_mother_cell
      ,CONVERT(VARCHAR(125),suf.parent_motherdayphone) AS ps_mother_day
      ,CONVERT(VARCHAR(125),suf.father_cell) AS ps_father_cell
      ,CONVERT(VARCHAR(125),suf.parent_fatherdayphone) AS ps_father_day
      ,CONVERT(VARCHAR(125),suf.emerg_4_name) AS ps_emerg_4_name
      ,CONVERT(VARCHAR(125),suf.emerg_4_rel) AS ps_emerg_4_rel
      ,CONVERT(VARCHAR(125),suf.emerg_4_phone) AS ps_emerg_4_phone
      ,CONVERT(VARCHAR(125),suf.emerg_5_name) AS ps_emerg_5_name
      ,CONVERT(VARCHAR(125),suf.emerg_5_rel) AS ps_emerg_5_rel
      ,CONVERT(VARCHAR(125),suf.emerg_5_phone) AS ps_emerg_5_phone
      ,CONVERT(VARCHAR(125),suf.release_1_name) AS ps_release_1_name
      ,CONVERT(VARCHAR(125),suf.release_1_phone) AS ps_release_1_phone
      ,CONVERT(VARCHAR(125),suf.release_1_relation) AS ps_release_1_relation
      ,CONVERT(VARCHAR(125),suf.release_2_name) AS ps_release_2_name
      ,CONVERT(VARCHAR(125),suf.release_2_phone) AS ps_release_2_phone
      ,CONVERT(VARCHAR(125),suf.release_2_relation) AS ps_release_2_relation
      ,CONVERT(VARCHAR(125),suf.release_3_name) AS ps_release_3_name
      ,CONVERT(VARCHAR(125),suf.release_3_phone) AS ps_release_3_phone
      ,CONVERT(VARCHAR(125),suf.release_3_relation) AS ps_release_3_relation
      ,CONVERT(VARCHAR(125),suf.release_4_name) AS ps_release_4_name
      ,CONVERT(VARCHAR(125),suf.release_4_phone) AS ps_release_4_phone
      ,CONVERT(VARCHAR(125),suf.release_4_relation) AS ps_release_4_relation
      ,CONVERT(VARCHAR(125),suf.release_5_name) AS ps_release_5_name
      ,CONVERT(VARCHAR(125),suf.release_5_phone) AS ps_release_5_phone
      ,CONVERT(VARCHAR(125),suf.release_5_relation) AS ps_release_5_relation
FROM gabby.alumni.ktc_roster r
LEFT JOIN enrollments enr
  ON r.sf_contact_id = enr.salesforce_contact_id
 AND enr.rn = 1
LEFT JOIN gabby.powerschool.students s
  ON r.student_number = s.student_number
 AND r.exit_db_name= s.db_name
LEFT JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
 AND s.db_name = suf.db_name
LEFT JOIN gabby.powerschool.studentcorefields scf
  ON s.dcid = scf.studentsdcid
 AND s.db_name = scf.db_name
WHERE r.ktc_status = 'TAF'