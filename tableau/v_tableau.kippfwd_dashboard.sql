USE gabby
GO

CREATE OR ALTER VIEW tableau.kippfwd_dashboard AS

WITH academic_years AS (
  SELECT gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year UNION
  SELECT gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
 )

,apps AS (
  SELECT app.sf_contact_id
        ,app.application_id
        ,app.application_name
        ,app.application_account_type
        ,app.transfer_application
        ,app.application_submission_status
        ,app.application_status
        ,app.matriculation_decision
        ,app.honors_special_program_name
        ,app.honors_special_program_status
        ,app.application_enrollment_status
        ,app.application_pursuing_degree_type
        ,CASE WHEN app.application_submission_status = 'Submitted' THEN 1 END AS is_submitted
        ,CASE WHEN app.application_status = 'Accepted' THEN 1 END AS is_accepted
        ,CASE WHEN app.type_for_roll_ups = 'College' THEN 1 END AS is_college
        ,CASE WHEN app.type_for_roll_ups IN ('Alternative Program', 'Organization', 'Other') THEN 1 END AS is_cert
        ,CASE WHEN app.application_account_type IN ('Public 2 yr', 'Private 2 yr') THEN 1 END AS is_2yr
        ,CASE WHEN app.application_account_type IN ('Private 4 yr', 'Public 4 yr') THEN 1 END AS is_4yr
        ,CASE
          WHEN app.matriculation_decision = 'Matriculated (Intent to Enroll)' 
           AND app.transfer_application = 0
               THEN 1
         END AS is_matriculated
        ,CASE
          WHEN app.application_submission_status = 'Submitted'
           AND app.honors_special_program_name = 'EOF/EOP'
           AND app.honors_special_program_status IN ('Applied', 'Accepted')
               THEN 1 
         END AS is_eof
        ,ROW_NUMBER() OVER(
           PARTITION BY app.sf_contact_id, app.matriculation_decision, app.transfer_application
             ORDER BY app.enrollment_start_date) AS rn
  FROM gabby.alumni.application_identifiers app
 )

,apps_rollup AS (
  SELECT sf_contact_id
        ,MAX(is_eof) AS is_eof_applicant
        ,MAX(is_matriculated) AS is_matriculated

        ,SUM(is_submitted) AS n_submitted
        ,MAX(CASE
              WHEN is_submitted = 1
               AND is_college = 1
               AND is_2yr = 1
                   THEN 1
             END) AS is_submitted_aa
        ,MAX(CASE 
              WHEN is_submitted = 1
               AND is_college = 1
               AND is_4yr = 1
                   THEN 1
             END) AS is_submitted_ba
        ,MAX(CASE 
              WHEN is_submitted = 1
               AND is_cert = 1
                   THEN 1
             END) AS is_submitted_cert

        ,SUM(is_accepted) AS n_accepted
        ,MAX(CASE 
              WHEN is_submitted = 1
               AND is_college = 1
               AND is_2yr = 1
               AND is_accepted = 1
                   THEN 1
             END) AS is_accepted_aa
        ,MAX(CASE 
              WHEN is_submitted = 1
               AND is_college = 1
               AND is_4yr = 1
               AND is_accepted = 1
                   THEN 1
             END) AS is_accepted_ba
        ,MAX(CASE 
              WHEN is_submitted = 1
               AND is_cert = 1
               AND is_accepted =1
                   THEN 1
             END) AS is_accepted_cert
  FROM apps
  GROUP BY sf_contact_id
 )

,semester_gpa AS (
  SELECT sf_contact_id
        ,academic_year
        ,semester
        ,CONVERT(NVARCHAR(16), transcript_date) AS transcript_date
        ,CONVERT(NVARCHAR(16), semester_gpa) AS semester_gpa
        ,CONVERT(NVARCHAR(16), cumulative_gpa) AS cumulative_gpa
        ,CONVERT(NVARCHAR(16), semester_credits_earned) AS semester_credits_earned
        ,CONVERT(NVARCHAR(16), cumulative_credits_earned) AS cumulative_credits_earned
        ,CONVERT(NVARCHAR(16), credits_required_for_graduation) AS credits_required_for_graduation
        ,ROW_NUMBER() OVER(
           PARTITION BY sf_contact_id, academic_year, semester
             ORDER BY transcript_date DESC) AS rn_semester
  FROM
      (
       SELECT gpa.student_c AS sf_contact_id
             ,gpa.transcript_date_c AS transcript_date
             ,gpa.semester_gpa_c AS semester_gpa
             ,gpa.gpa_c AS cumulative_gpa
             ,gpa.semester_credits_earned_c AS semester_credits_earned
             ,gpa.cumulative_credits_earned_c AS cumulative_credits_earned
             ,gpa.credits_required_for_graduation_c AS credits_required_for_graduation
             ,gabby.utilities.DATE_TO_SY(gpa.transcript_date_c) AS academic_year
             ,CASE
               WHEN MONTH(gpa.transcript_date_c) = 1 THEN 'fall'
               WHEN MONTH(gpa.transcript_date_c) = 5 THEN 'spr'
              END AS semester
       FROM gabby.alumni.gpa_c gpa
       JOIN gabby.alumni.record_type rt
         ON gpa.record_type_id = rt.id
        AND rt.[name] = 'Cumulative College'
       WHERE gpa.is_deleted = 0
      ) sub
 )

,semester_gpa_pivot AS ( 
  SELECT sf_contact_id
        ,academic_year
        ,CONVERT(DATE, fall_transcript_date) AS fall_transcript_date
        ,CONVERT(FLOAT, fall_credits_required_for_graduation) AS fall_credits_required_for_graduation
        ,CONVERT(FLOAT, fall_cumulative_credits_earned) AS fall_cumulative_credits_earned
        ,CONVERT(FLOAT, fall_semester_credits_earned) AS fall_semester_credits_earned
        ,CONVERT(FLOAT, fall_semester_gpa) AS fall_semester_gpa
        ,CONVERT(FLOAT, fall_cumulative_gpa) AS fall_cumulative_gpa
        ,CONVERT(DATE, spr_transcript_date) AS spr_transcript_date
        ,CONVERT(FLOAT, spr_credits_required_for_graduation) AS spr_credits_required_for_graduation
        ,CONVERT(FLOAT, spr_cumulative_credits_earned) AS spr_cumulative_credits_earned
        ,CONVERT(FLOAT, spr_semester_credits_earned) AS spr_semester_credits_earned
        ,CONVERT(FLOAT, spr_semester_gpa) AS spr_semester_gpa
        ,CONVERT(FLOAT, spr_cumulative_gpa) AS spr_cumulative_gpa
  FROM
      (
       SELECT sf_contact_id
             ,academic_year
             ,[value]
             ,semester + '_' + field AS pivot_field
       FROM semester_gpa
       UNPIVOT(
         [value]
         FOR field IN (transcript_date, semester_gpa, cumulative_gpa, semester_credits_earned, cumulative_credits_earned, credits_required_for_graduation)
        ) u
       WHERE rn_semester = 1
      ) sub
  PIVOT(
  MAX([value])
  FOR pivot_field IN (
     fall_credits_required_for_graduation
    ,fall_cumulative_credits_earned
    ,fall_cumulative_gpa
    ,fall_semester_credits_earned
    ,fall_semester_gpa
    ,fall_transcript_date
    ,spr_credits_required_for_graduation
    ,spr_cumulative_credits_earned
    ,spr_cumulative_gpa
    ,spr_semester_credits_earned
    ,spr_semester_gpa
    ,spr_transcript_date)
   ) p
 )

SELECT c.sf_contact_id
      ,c.lastfirst AS student_name
      ,c.ktc_cohort
      ,c.is_kipp_ms_graduate
      ,c.is_kipp_hs_graduate
      ,c.expected_hs_graduation_date
      ,c.actual_hs_graduation_date
      ,c.expected_college_graduation_date
      ,c.actual_college_graduation_date
      ,c.current_kipp_student
      ,c.highest_act_score
      ,c.record_type_name
      ,c.counselor_name
      ,c.college_match_display_gpa
      ,c.current_college_cumulative_gpa
      ,c.kipp_region_name
      ,c.kipp_region_school
      ,c.post_hs_simple_admin
      ,c.ktc_status
      ,c.currently_enrolled_school
      ,c.latest_fafsa_date
      ,c.latest_state_financial_aid_app_date
      ,c.latest_resume_date
      ,c.efc_from_fafsa
      ,c.ethnicity
      ,c.gender
      ,c.last_successful_contact_date
      ,c.last_successful_advisor_contact_date
      ,c.last_outreach_date
      ,c.contact_description
      ,c.high_school_graduated_from
      ,c.college_graduated_from
      ,c.current_college_semester_gpa

      ,ay.academic_year

      ,ei.cur_school_name
      ,ei.cur_account_type
      ,ei.cur_pursuing_degree_type
      ,ei.cur_status
      ,ei.cur_start_date
      ,ei.cur_actual_end_date
      ,ei.cur_anticipated_graduation
      ,ei.cur_credits_required_for_graduation
      ,ei.cur_date_last_verified
      ,ei.ecc_school_name
      ,ei.ecc_account_type
      ,ei.ecc_pursuing_degree_type
      ,ei.ecc_status
      ,ei.ecc_start_date
      ,ei.ecc_actual_end_date
      ,ei.ecc_anticipated_graduation
      ,ei.ecc_credits_required_for_graduation
      ,ei.ecc_date_last_verified
      ,ei.emp_status
      ,ei.emp_category
      ,ei.emp_date_last_verified
      ,ei.emp_start_date
      ,ei.emp_actual_end_date
      ,ei.emp_billing_state
      ,ei.emp_ncesid
      ,ei.emp_name
      ,ei.ba_status
      ,ei.ba_actual_end_date
      ,ei.aa_status
      ,ei.aa_actual_end_date
      ,ei.cte_status
      ,ei.cte_actual_end_date

      ,ar.n_submitted
      ,ar.is_submitted_aa
      ,ar.is_submitted_ba
      ,ar.is_submitted_cert
      ,ar.n_accepted
      ,ar.is_accepted_aa
      ,ar.is_accepted_ba
      ,ar.is_accepted_cert
      ,ar.is_eof_applicant
      ,ar.is_matriculated

      ,cnr.[AS1F]
      ,cnr.[AS2F]
      ,cnr.[AS3F]
      ,cnr.[AS4F]
      ,cnr.[AS5F]
      ,cnr.[AS6F]
      ,cnr.[AS1S]
      ,cnr.[AS2S]
      ,cnr.[AS3S]
      ,cnr.[AS4S]
      ,cnr.[AS5S]
      ,cnr.[AS6S]
      ,cnr.[AS1F_date]
      ,cnr.[AS2F_date]
      ,cnr.[AS3F_date]
      ,cnr.[AS4F_date]
      ,cnr.[AS5F_date]
      ,cnr.[AS6F_date]
      ,cnr.[AS1S_date]
      ,cnr.[AS2S_date]
      ,cnr.[AS3S_date]
      ,cnr.[AS4S_date]
      ,cnr.[AS5S_date]
      ,cnr.[AS6S_date]

      ,cnr.CCDM
      ,cnr.PSCF
      ,cnr.PSCS
      ,cnr.SC
      ,cnr.HV
      ,cnr.DP_2yearF
      ,cnr.DP_4yearF
      ,cnr.DP_CTEF
      ,cnr.DP_MilitaryF
      ,cnr.DP_WorkforceF
      ,cnr.DP_UnknownF
      ,cnr.DP_2yearS
      ,cnr.DP_4yearS
      ,cnr.DP_CTES
      ,cnr.DP_MilitaryS
      ,cnr.DP_WorkforceS
      ,cnr.DP_UnknownS


      ,gpa.fall_transcript_date
      ,gpa.fall_semester_gpa
      ,gpa.fall_cumulative_gpa
      ,gpa.fall_semester_credits_earned
      ,COALESCE(
         gpa.fall_cumulative_credits_earned
        ,LAG(gpa.spr_cumulative_credits_earned, 1) OVER(PARTITION BY c.sf_contact_id ORDER BY ay.academic_year ASC) /* prev spring */
        ,LAG(gpa.fall_cumulative_credits_earned, 1) OVER(PARTITION BY c.sf_contact_id ORDER BY ay.academic_year ASC) /* prev fall */
       ) AS fall_cumulative_credits_earned
      
      ,gpa.spr_transcript_date
      ,gpa.spr_semester_gpa
      ,gpa.spr_cumulative_gpa
      ,gpa.spr_semester_credits_earned
      ,COALESCE(
         gpa.spr_cumulative_credits_earned
        ,gpa.fall_cumulative_credits_earned
        ,LAG(gpa.spr_cumulative_credits_earned, 1) OVER(PARTITION BY c.sf_contact_id ORDER BY ay.academic_year ASC) /* prev spring */
        ,LAG(gpa.fall_cumulative_credits_earned, 1) OVER(PARTITION BY c.sf_contact_id ORDER BY ay.academic_year ASC) /* prev fall */
       ) AS spr_cumulative_credits_earned

      ,LAG(gpa.spr_semester_credits_earned, 1) OVER(PARTITION BY c.sf_contact_id ORDER BY ay.academic_year ASC) prev_spr_semester_credits_earned
FROM gabby.alumni.ktc_roster c
CROSS JOIN academic_years ay
LEFT JOIN gabby.alumni.enrollment_identifiers ei
  ON c.sf_contact_id = ei.student_c
LEFT JOIN apps_rollup ar
  ON c.sf_contact_id = ar.sf_contact_id
LEFT JOIN gabby.alumni.contact_note_rollup cnr
  ON c.sf_contact_id = cnr.contact_id
 AND ay.academic_year = cnr.academic_year
LEFT JOIN semester_gpa_pivot gpa
  ON c.sf_contact_id = gpa.sf_contact_id
 AND ay.academic_year = gpa.academic_year
WHERE c.ktc_status IN ('HS9', 'HS10', 'HS11', 'HS12', 'HSG', 'TAF', 'TAFHS')
  AND c.sf_contact_id IS NOT NULL
