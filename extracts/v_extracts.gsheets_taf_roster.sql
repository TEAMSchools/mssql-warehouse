USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_taf_roster AS

SELECT student_number
      ,lastfirst
      ,school_name
      ,approx_grade_level
      ,first_name
      ,last_name
      ,CONVERT(NVARCHAR,dob) AS dob
      ,CONVERT(NVARCHAR,exitdate) AS exitdate
      ,is_grad
      ,cohort
      ,CONVERT(NVARCHAR,expected_hs_graduation_date) AS expected_hs_graduation_date
      ,ktc_counselor
      ,enrollment_type
      ,enrollment_name
      ,enrollment_status
      ,sf_home_phone
      ,sf_mobile_phone
      ,sf_other_phone
      ,sf_email
      ,ps_email
      ,ps_home_phone
      ,ps_mother
      ,ps_mother_home
      ,ps_mother_cell
      ,ps_mother_day
      ,ps_father
      ,ps_father_home
      ,ps_father_cell
      ,ps_father_day
      ,ps_doctor_name
      ,ps_doctor_phone
      ,ps_emerg_contact_1
      ,ps_emerg_1_rel
      ,ps_emerg_phone_1
      ,ps_emerg_contact_2
      ,ps_emerg_2_rel
      ,ps_emerg_phone_2
      ,ps_emerg_contact_3
      ,ps_emerg_3_rel
      ,ps_emerg_3_phone
      ,ps_emerg_4_name
      ,ps_emerg_4_rel
      ,ps_emerg_4_phone
      ,ps_emerg_5_name
      ,ps_emerg_5_rel
      ,ps_emerg_5_phone
      ,ps_release_1_name
      ,ps_release_1_phone
      ,ps_release_1_relation
      ,ps_release_2_name
      ,ps_release_2_phone
      ,ps_release_2_relation
      ,ps_release_3_name
      ,ps_release_3_phone
      ,ps_release_3_relation
      ,ps_release_4_name
      ,ps_release_4_phone
      ,ps_release_4_relation
      ,ps_release_5_name
      ,ps_release_5_phone
      ,ps_release_5_relation
FROM gabby.alumni.taf_roster