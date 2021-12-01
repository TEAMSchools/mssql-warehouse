USE gabby
GO

CREATE OR ALTER VIEW alumni.ktc_roster AS

SELECT sub.student_number
      ,sub.studentid
      ,sub.lastfirst
      ,sub.first_name
      ,sub.last_name
      ,sub.exit_academic_year
      ,sub.exit_schoolid
      ,sub.exit_school_name
      ,sub.exit_grade_level
      ,sub.exit_date
      ,sub.exit_code
      ,sub.exit_db_name
      ,sub.current_grade_level_projection
      ,sub.sf_contact_id
      ,sub.ktc_cohort
      ,sub.kipp_region_name
      ,sub.kipp_region_school
      ,sub.is_kipp_ms_graduate
      ,sub.is_kipp_hs_graduate
      ,sub.is_informed_consent
      ,sub.is_transcript_release
      ,sub.expected_hs_graduation_date
      ,sub.actual_hs_graduation_date
      ,sub.expected_college_graduation_date
      ,sub.actual_college_graduation_date
      ,sub.latest_transcript_date
      ,sub.latest_fafsa_date
      ,sub.latest_state_financial_aid_app_date
      ,sub.efc_from_fafsa
      ,sub.cumulative_gpa
      ,sub.current_college_cumulative_gpa
      ,sub.current_college_semester_gpa
      ,sub.college_match_display_gpa
      ,sub.highest_act_score
      ,sub.college_credits_attempted
      ,sub.accumulated_credits_college
      ,sub.sf_mobile_phone
      ,sub.sf_home_phone
      ,sub.sf_other_phone
      ,sub.sf_email
      ,sub.current_kipp_student
      ,sub.post_hs_simple_admin
      ,sub.college_status
      ,sub.currently_enrolled_school
      ,sub.middle_school_attended
      ,sub.high_school_graduated_from
      ,sub.college_graduated_from
      ,sub.gender
      ,sub.ethnicity
      ,sub.contact_description
      ,sub.latest_resume_date
      ,sub.last_outreach_date
      ,sub.last_successful_contact_date
      ,sub.last_successful_advisor_contact_date
      ,sub.years_out_of_hs
      ,sub.record_type_name
      ,sub.counselor_sf_id
      ,sub.counselor_name
      ,sub.counselor_email
      ,sub.counselor_phone
      ,sub.ktc_status
FROM 
    (
     SELECT co.student_number
           ,co.studentid
           ,co.academic_year AS exit_academic_year
           ,co.schoolid AS exit_schoolid
           ,co.school_name AS exit_school_name
           ,co.grade_level AS exit_grade_level
           ,co.exitdate AS exit_date
           ,co.exitcode AS exit_code
           ,co.[db_name] AS exit_db_name
           ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - co.academic_year) + co.grade_level AS current_grade_level_projection

           ,c.id AS sf_contact_id
           ,c.kipp_region_name_c AS kipp_region_name
           ,c.kipp_region_school_c AS kipp_region_school
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
           ,c.current_college_cumulative_gpa_c AS current_college_cumulative_gpa
           ,c.current_college_semester_gpa_c AS current_college_semester_gpa
           ,c.college_match_display_gpa_c AS college_match_display_gpa
           ,c.highest_act_score_c AS highest_act_score
           ,c.college_credits_attempted_c AS college_credits_attempted
           ,c.accumulated_credits_college_c AS accumulated_credits_college
           ,c.mobile_phone AS sf_mobile_phone
           ,c.home_phone AS sf_home_phone
           ,c.other_phone AS sf_other_phone
           ,c.email AS sf_email
           ,c.post_hs_simple_admin_c AS post_hs_simple_admin
           ,c.college_status_c AS college_status
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
           ,c.efc_from_fafsa_c AS efc_from_fafsa
           ,c.[description] AS contact_description
           ,COALESCE(c.current_kipp_student_c, 'Missing from Salesforce') AS current_kipp_student
           ,COALESCE(c.kipp_hs_class_c, co.cohort) AS ktc_cohort
           ,(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1) - DATEPART(YEAR, c.actual_hs_graduation_date_c) AS years_out_of_hs

           ,rt.[name] AS record_type_name

           ,u.id AS counselor_sf_id
           ,u.[name] AS counselor_name
           ,u.email AS counselor_email
           ,u.mobile_phone AS counselor_phone

           ,COALESCE(c.first_name, co.first_name) COLLATE LATIN1_GENERAL_BIN AS first_name
           ,COALESCE(c.last_name, co.last_name) COLLATE LATIN1_GENERAL_BIN AS last_name
           ,COALESCE(c.last_name + ', ' + c.first_name, co.lastfirst) COLLATE LATIN1_GENERAL_BIN AS lastfirst

           ,CASE
             WHEN c.kipp_hs_graduate_c = 1 THEN 'HSG'
             WHEN co.school_level = 'HS' AND co.exitcode = 'G1' THEN 'HSG'
             WHEN c.kipp_ms_graduate_c = 1 AND c.kipp_hs_graduate_c = 0 AND rt.[name] = 'HS Student' THEN 'TAFHS'
             WHEN c.kipp_ms_graduate_c = 1 AND c.kipp_hs_graduate_c = 0 THEN 'TAF'
             WHEN co.enroll_status = 0 THEN CONCAT('HS', co.grade_level)
             WHEN rt.[name] = 'HS Student'
              AND co.grade_level = 8
              AND MONTH(co.exitdate) IN (6, 7)
              AND (co.exitcode = 'G1' OR co.exitcode LIKE 'T%' AND co.exitcode <> 'T2')
                  THEN 'TAFHS'
             WHEN co.grade_level = 8
              AND MONTH(co.exitdate) IN (6, 7)
              AND (co.exitcode = 'G1' OR co.exitcode LIKE 'T%' AND co.exitcode <> 'T2')
                  THEN 'TAF'
            END AS ktc_status
     FROM gabby.powerschool.cohort_identifiers_static co
     LEFT JOIN gabby.alumni.contact c
       ON co.student_number = c.school_specific_id_c
      AND c.is_deleted = 0
     LEFT JOIN gabby.alumni.record_type rt
       ON c.record_type_id = rt.id
     LEFT JOIN gabby.alumni.[user] u
       ON c.owner_id = u.id
     WHERE co.rn_undergrad = 1
       AND co.grade_level <> 99
    ) sub
WHERE sub.ktc_status IS NOT NULL
