USE gabby
GO 

CREATE OR ALTER VIEW tableau.ktc_goals_dashboard AS

SELECT c.student_number
      ,c.studentid
      ,c.lastfirst
      ,c.first_name
      ,c.last_name
      ,c.exit_academic_year
      ,c.exit_schoolid
      ,c.exit_school_name
      ,c.exit_grade_level
      ,c.exit_date
      ,c.exit_code
      ,c.exit_db_name
      ,c.current_grade_level_projection
      ,c.sf_contact_id
      ,c.ktc_cohort
      ,c.kipp_region_name
      ,c.is_kipp_ms_graduate
      ,c.is_kipp_hs_graduate
      ,c.is_informed_consent
      ,c.is_transcript_release
      ,c.expected_hs_graduation_date
      ,c.actual_hs_graduation_date
      ,c.expected_college_graduation_date
      ,c.actual_college_graduation_date
      ,c.latest_transcript_date
      ,c.latest_fafsa_date
      ,c.latest_state_financial_aid_app_date
      ,c.cumulative_gpa
      ,c.current_college_semester_gpa
      ,c.college_match_display_gpa
      ,c.highest_act_score
      ,c.college_credits_attempted
      ,c.accumulated_credits_college
      ,c.sf_mobile_phone
      ,c.sf_home_phone
      ,c.sf_other_phone
      ,c.sf_email
      ,c.current_kipp_student
      ,c.post_hs_simple_admin
      ,c.college_status
      ,c.currently_enrolled_school
      ,c.middle_school_attended
      ,c.high_school_graduated_from
      ,c.college_graduated_from
      ,c.gender
      ,c.ethnicity
      ,c.latest_resume_date
      ,c.last_outreach_date
      ,c.last_successful_contact_date
      ,c.last_successful_advisor_contact_date
      ,c.years_out_of_hs
      ,c.record_type_name
      ,c.counselor_sf_id
      ,c.counselor_name
      ,c.ktc_status

      ,e.student_c
      ,e.recent_ugrad_enrollment_c
      ,e.ecc_enrollment_c
      ,e.hs_enrollment_c
      ,e.vocational_enrollment_id
      ,e.graduate_enrollment_id
      ,e.ugrad_school_name
      ,e.ugrad_pursuing_degree_type
      ,e.ugrad_status
      ,e.ugrad_start_date
      ,e.ugrad_actual_end_date
      ,e.ugrad_anticipated_graduation
      ,e.ugrad_account_type
      ,e.ugrad_major
      ,e.ugrad_major_area
      ,e.ugrad_college_major_declared
      ,e.ugrad_date_last_verified
      ,e.ugrad_account_name
      ,e.ugrad_billing_state
      ,e.ugrad_ncesid
      ,e.ecc_school_name
      ,e.ecc_pursuing_degree_type
      ,e.ecc_status
      ,e.ecc_start_date
      ,e.ecc_actual_end_date
      ,e.ecc_anticipated_graduation
      ,e.ecc_account_type
      ,e.ecc_adjusted_6_year_minority_graduation_rate
      ,e.hs_school_name
      ,e.hs_pursuing_degree_type
      ,e.hs_status
      ,e.hs_start_date
      ,e.hs_actual_end_date
      ,e.hs_anticipated_graduation
      ,e.hs_account_type
      ,e.cte_school_name
      ,e.cte_pursuing_degree_type
      ,e.cte_status
      ,e.cte_start_date
      ,e.cte_actual_end_date
      ,e.cte_anticipated_graduation
      ,e.cte_account_type

      ,cn.contact_id
      ,cn.academic_year
      ,cn.SM2Q4
      ,cn.SM2Q3
      ,cn.SM2Q2
      ,cn.SM2Q1
      ,cn.SM1Q4
      ,cn.SM1Q3
      ,cn.SM1Q2
      ,cn.SM1Q1
      ,cn.MC2
      ,cn.MC1
      ,cn.GPS
      ,cn.GPF
      ,cn.BMS
      ,cn.BMF
      ,cn.BBBS
      ,cn.BBBF
      ,cn.PSCS
      ,cn.PSCF
      ,cn.AAS4S
      ,cn.AAS4F
      ,cn.AAS3S
      ,cn.AAS3F
      ,cn.AAS2S
      ,cn.AAS1S
      ,cn.AAS2F
      ,cn.AAS1F
      ,cn.AASS

      --,app.[2YR] AS N_2YR_apps
      --,app.[4YR] AS N_4YR_apps
      --,app.[2YR_T] AS N_2YR_transfer_apps
      --,app.[4YR_T] AS N_4YR_transfer_apps
      --,app.[ALL] AS N_apps_all

      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS current_academic_year
FROM gabby.alumni.ktc_roster c 
LEFT JOIN gabby.alumni.enrollment_identifiers e
  ON c.sf_contact_id = e.student_c
LEFT JOIN gabby.alumni.contact_note_rollup cn
  ON c.sf_contact_id = cn.contact_id
 AND cn.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()