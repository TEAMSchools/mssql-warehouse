USE gabby
GO

CREATE OR ALTER VIEW alumni.ktc_roster AS

WITH ps_roster AS (
  SELECT co.student_number
        ,co.studentid
        ,co.lastfirst
        ,co.academic_year AS exit_academic_year
        ,co.schoolid AS exit_schoolid
        ,co.school_name AS exit_school_name
        ,co.grade_level AS exit_grade_level
        ,co.exitdate AS exit_date
        ,co.exitcode AS exit_code
        ,co.db_name AS exit_db_name
        ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - co.academic_year) + co.grade_level AS current_grade_level_projection
        ,CASE
          WHEN co.grade_level = 8 AND co.exitcode IN ('G1', 'T2') THEN 'TAF'
          WHEN co.school_level = 'HS' AND co.exitcode = 'G1' THEN 'HSG'
          WHEN co.grade_level IN (11, 12) AND co.enroll_status = 0 THEN CONCAT('HS', co.grade_level)
         END AS ktc_status
  FROM gabby.powerschool.cohort_identifiers_static co
  WHERE co.rn_undergrad = 1
 )

SELECT pr.student_number
      ,pr.studentid
      ,pr.lastfirst
      ,pr.exit_academic_year
      ,pr.exit_schoolid
      ,pr.exit_school_name
      ,pr.exit_grade_level
      ,pr.exit_date
      ,pr.exit_code
      ,pr.exit_db_name
      ,pr.current_grade_level_projection
      ,pr.ktc_status

      ,c.id AS sf_contact_id
      ,c.kipp_hs_class_c AS ktc_cohort
      ,c.kipp_ms_graduate_c AS is_kipp_ms_graduate
      ,c.kipp_hs_graduate_c AS is_kipp_hs_graduate
      ,c.informed_consent_c AS is_informed_consent
      ,c.transcript_release_c AS is_transcript_release
      ,c.expected_hs_graduation_c AS expected_hs_graduation_date
      ,c.actual_hs_graduation_date_c AS actual_hs_graduation_date
      ,c.expected_college_graduation_c AS expected_college_graduation_date
      ,c.actual_college_graduation_date_c AS actual_college_graduation_date
      ,c.latest_transcript_c AS latest_transcript_date
      ,c.latest_fafsa_date_c AS latest_fafsa_date
      ,c.latest_state_financial_aid_app_date_c AS latest_state_financial_aid_app_date
      ,c.cumulative_gpa_c AS cumulative_gpa
      ,c.college_match_display_gpa_c AS college_match_display_gpa
      ,c.highest_act_score_c AS highest_act_score
      ,c.college_credits_attempted_c AS college_credits_attempted
      ,c.accumulated_credits_college_c AS accumulated_credits_college
      ,c.mobile_phone AS sf_mobile_phone
      ,c.home_phone AS sf_home_phone
      ,c.other_phone AS sf_other_phone
      ,c.email AS sf_email
      ,c.post_hs_simple_admin_c AS post_hs_simple_admin
      ,c.currently_enrolled_school_c AS currently_enrolled_school
      ,c.middle_school_attended_c AS middle_school_attended
      ,c.high_school_graduated_from_c AS high_school_graduated_from
      ,c.college_graduated_from_c AS college_graduated_from
      ,c.gender_c AS gender
      ,c.ethnicity_c AS ethnicity
      ,c.latest_resume_c AS latest_resume_date
      ,c.last_outreach_c AS last_outreach_date
      ,c.last_successful_contact_c AS last_successful_contact_date
      ,c.last_successful_advisor_contact_c AS last_successful_advisor_contact_date
      ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1) - DATEPART(YEAR, c.actual_hs_graduation_date_c) AS years_out_of_hs

      ,rt.[name] AS record_type_name

      ,u.id AS counselor_sf_id
      ,u.[name] AS counselor_name
FROM ps_roster pr
LEFT JOIN gabby.alumni.contact c
  ON pr.student_number = c.school_specific_id_c
LEFT JOIN gabby.alumni.record_type rt
  ON c.record_type_id = rt.id
LEFT JOIN gabby.alumni.[user] u
  ON c.owner_id = u.id
WHERE pr.ktc_status IS NOT NULL