USE gabby
GO 

CREATE OR ALTER VIEW tableau.ktc_goals_dashboard AS

SELECT c.student_number
      ,c.sf_contact_id
      ,c.lastfirst
      ,c.first_name
      ,c.last_name
      ,c.ktc_cohort
      ,c.ktc_status
      ,c.record_type_name
      ,c.post_hs_simple_admin
      ,c.current_kipp_student
      ,c.counselor_sf_id
      ,c.counselor_name
      ,c.exit_academic_year
      ,c.exit_schoolid
      ,c.exit_school_name
      ,c.exit_grade_level
      ,c.exit_date
      ,c.exit_code
      ,c.exit_db_name
      ,c.current_grade_level_projection
      ,c.is_kipp_ms_graduate
      ,c.is_kipp_hs_graduate
      ,c.kipp_region_name
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
      ,c.college_status
      ,c.currently_enrolled_school
      ,c.middle_school_attended
      ,c.high_school_graduated_from
      ,c.college_graduated_from
      ,c.latest_resume_date
      ,c.last_outreach_date
      ,c.last_successful_contact_date
      ,c.last_successful_advisor_contact_date
      ,c.years_out_of_hs

      , e.student_c
      ,e.ugrad_enrollment_id
      ,e.ecc_enrollment_id
      ,e.hs_enrollment_id
      ,e.cte_enrollment_id
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
      ,e.cte_pursuing_degree_type
      ,e.cte_status
      ,e.cte_start_date
      ,e.cte_actual_end_date
      ,e.cte_anticipated_graduation
      ,e.cte_account_type
      ,e.cte_school_name
      ,e.cte_billing_state
      ,e.cte_ncesid
      ,e.cur_pursuing_degree_type
      ,e.cur_status
      ,e.cur_start_date
      ,e.cur_actual_end_date
      ,e.cur_anticipated_graduation
      ,e.cur_account_type
      ,e.cur_school_name
      ,e.cur_billing_state
      ,e.cur_ncesid

      ,cn.SM1Q1
      ,cn.SM2Q1
      ,cn.SM1Q2
      ,cn.SM2Q2
      ,cn.SM1Q3
      ,cn.SM2Q3
      ,cn.SM1Q4
      ,cn.SM2Q4
      ,cn.MC1
      ,cn.MC2
      ,cn.GPF
      ,cn.GPS
      ,cn.BMF
      ,cn.BMS
      ,cn.BBBF
      ,cn.BBBS
      ,cn.PSCF
      ,cn.PSCS
      ,cn.AASS
      ,cn.AAS1F
      ,cn.AAS2F
      ,cn.AAS3F
      ,cn.AAS4F
      ,cn.AAS1S
      ,cn.AAS2S
      ,cn.AAS3S
      ,cn.AAS4S

      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS current_academic_year
FROM gabby.alumni.ktc_roster c 
LEFT JOIN gabby.alumni.enrollment_identifiers e
  ON c.sf_contact_id = e.student_c
LEFT JOIN gabby.alumni.contact_note_rollup cn
  ON c.sf_contact_id = cn.contact_id
 AND cn.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()