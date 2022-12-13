USE gabby GO
CREATE OR ALTER VIEW
  tableau.ktc_goals_dashboard AS
WITH
  app_rollup AS (
    SELECT
      sf_contact_id,
      SUM(
        CASE
          WHEN is_ltr = 1
          AND is_submitted = 1 THEN 1
          ELSE 0
        END
      ) AS n_submitted_ltr,
      SUM(
        CASE
          WHEN is_ltr = 1
          AND is_wishlist = 1 THEN 1
          ELSE 0
        END
      ) AS n_wishlist_ltr,
      MAX(is_eof_applied) AS is_eof_applied,
      MAX(is_eof_accepted) AS is_eof_accepted,
      MAX(
        CASE
          WHEN is_submitted = 1
          AND is_4yr_college = 1 THEN 1
          ELSE 0
        END
      ) AS is_submitted_4yr,
      MAX(
        CASE
          WHEN is_submitted = 1
          AND is_2yr_college = 1 THEN 1
          ELSE 0
        END
      ) AS is_submitted_2yr,
      MAX(
        CASE
          WHEN is_submitted = 1
          AND is_cte = 1 THEN 1
          ELSE 0
        END
      ) AS is_submitted_cte,
      MAX(
        CASE
          WHEN is_accepted = 1
          AND is_4yr_college = 1 THEN 1
          ELSE 0
        END
      ) AS is_accepted_4yr,
      MAX(
        CASE
          WHEN is_accepted = 1
          AND is_2yr_college = 1 THEN 1
          ELSE 0
        END
      ) AS is_accepted_2yr,
      MAX(
        CASE
          WHEN is_accepted = 1
          AND is_cte = 1 THEN 1
          ELSE 0
        END
      ) AS is_accepted_cte,
      MAX(
        CASE
          WHEN is_early_actiondecision = 1
          AND is_submitted = 1
          AND is_4yr_college = 1 THEN 1
          ELSE 0
        END
      ) AS is_submitted_eaed_4yr,
      MAX(
        CASE
          WHEN is_early_actiondecision = 1
          AND is_accepted = 1
          AND is_4yr_college = 1 THEN 1
          ELSE 0
        END
      ) AS is_accepted_eaed_4yr
    FROM
      gabby.alumni.application_identifiers
    GROUP BY
      sf_contact_id
  )
SELECT
  c.student_number,
  c.sf_contact_id,
  c.lastfirst,
  c.first_name,
  c.last_name,
  c.ktc_cohort,
  c.ktc_status,
  c.record_type_name,
  c.post_hs_simple_admin,
  c.current_kipp_student,
  c.counselor_sf_id,
  c.counselor_name,
  c.exit_academic_year,
  c.exit_schoolid,
  c.exit_school_name,
  c.exit_grade_level,
  c.exit_date,
  c.exit_code,
  c.exit_db_name,
  c.current_grade_level_projection,
  c.is_kipp_ms_graduate,
  c.is_kipp_hs_graduate,
  c.kipp_region_name,
  c.is_informed_consent,
  c.is_transcript_release,
  c.expected_hs_graduation_date,
  c.actual_hs_graduation_date,
  c.expected_college_graduation_date,
  c.actual_college_graduation_date,
  c.latest_transcript_date,
  c.latest_fafsa_date,
  c.latest_state_financial_aid_app_date,
  c.cumulative_gpa,
  c.current_college_semester_gpa,
  c.college_match_display_gpa,
  c.highest_act_score,
  c.college_credits_attempted,
  c.accumulated_credits_college,
  c.college_status,
  c.currently_enrolled_school,
  c.middle_school_attended,
  c.high_school_graduated_from,
  c.college_graduated_from,
  c.latest_resume_date,
  c.last_outreach_date,
  c.last_successful_contact_date,
  c.last_successful_advisor_contact_date,
  c.years_out_of_hs,
  e.student_c,
  e.ugrad_enrollment_id,
  e.ecc_enrollment_id,
  e.hs_enrollment_id,
  e.cte_enrollment_id,
  e.graduate_enrollment_id,
  e.ugrad_school_name,
  e.ugrad_pursuing_degree_type,
  e.ugrad_status,
  e.ugrad_start_date,
  e.ugrad_actual_end_date,
  e.ugrad_anticipated_graduation,
  e.ugrad_account_type,
  e.ugrad_major,
  e.ugrad_major_area,
  e.ugrad_college_major_declared,
  e.ugrad_date_last_verified,
  e.ugrad_account_name,
  e.ugrad_billing_state,
  e.ugrad_ncesid,
  e.ecc_school_name,
  e.ecc_pursuing_degree_type,
  e.ecc_status,
  e.ecc_start_date,
  e.ecc_actual_end_date,
  e.ecc_anticipated_graduation,
  e.ecc_account_type,
  e.ecc_adjusted_6_year_minority_graduation_rate,
  e.hs_school_name,
  e.hs_pursuing_degree_type,
  e.hs_status,
  e.hs_start_date,
  e.hs_actual_end_date,
  e.hs_anticipated_graduation,
  e.hs_account_type,
  e.cte_pursuing_degree_type,
  e.cte_status,
  e.cte_start_date,
  e.cte_actual_end_date,
  e.cte_anticipated_graduation,
  e.cte_account_type,
  e.cte_school_name,
  e.cte_billing_state,
  e.cte_ncesid,
  e.cur_pursuing_degree_type,
  e.cur_status,
  e.cur_start_date,
  e.cur_actual_end_date,
  e.cur_anticipated_graduation,
  e.cur_account_type,
  e.cur_school_name,
  e.cur_billing_state,
  e.cur_ncesid,
  e.cur_adjusted_6_year_minority_graduation_rate,
  ISNULL(cn.SM1Q1, 0) AS SM1Q1,
  ISNULL(cn.SM2Q1, 0) AS SM2Q1,
  ISNULL(cn.SM1Q2, 0) AS SM1Q2,
  ISNULL(cn.SM2Q2, 0) AS SM2Q2,
  ISNULL(cn.SM1Q3, 0) AS SM1Q3,
  ISNULL(cn.SM2Q3, 0) AS SM2Q3,
  ISNULL(cn.SM1Q4, 0) AS SM1Q4,
  ISNULL(cn.SM2Q4, 0) AS SM2Q4,
  ISNULL(cn.MC1, 0) AS MC1,
  ISNULL(cn.MC2, 0) AS MC2,
  ISNULL(cn.GPF, 0) AS GPF,
  ISNULL(cn.GPS, 0) AS GPS,
  ISNULL(cn.BMF, 0) AS BMF,
  ISNULL(cn.BMS, 0) AS BMS,
  ISNULL(cn.BBBF, 0) AS BBBF,
  ISNULL(cn.BBBS, 0) AS BBBS,
  ISNULL(cn.PSCF, 0) AS PSCF,
  ISNULL(cn.PSCS, 0) AS PSCS,
  ISNULL(cn.AASS, 0) AS AASS,
  ISNULL(cn.AAS1F, 0) AS AAS1F,
  ISNULL(cn.AAS2F, 0) AS AAS2F,
  ISNULL(cn.AAS3F, 0) AS AAS3F,
  ISNULL(cn.AAS4F, 0) AS AAS4F,
  ISNULL(cn.AAS1S, 0) AS AAS1S,
  ISNULL(cn.AAS2S, 0) AS AAS2S,
  ISNULL(cn.AAS3S, 0) AS AAS3S,
  ISNULL(cn.AAS4S, 0) AS AAS4S,
  ISNULL(ap.n_submitted_ltr, 0) AS n_submitted_ltr,
  ISNULL(ap.n_wishlist_ltr, 0) AS n_wishlist_ltr,
  ISNULL(ap.is_eof_applied, 0) AS is_eof_applied,
  ISNULL(ap.is_eof_accepted, 0) AS is_eof_accepted,
  ISNULL(ap.is_submitted_eaed_4yr, 0) AS is_submitted_eaed_4yr,
  ISNULL(ap.is_accepted_eaed_4yr, 0) AS is_accepted_eaed_4yr,
  ISNULL(ap.is_accepted_4yr, 0) AS is_accepted_4yr,
  ISNULL(ap.is_accepted_2yr, 0) AS is_accepted_2yr,
  ISNULL(ap.is_accepted_cte, 0) AS is_accepted_cte,
  ISNULL(ap.is_submitted_4yr, 0) AS is_submitted_4yr,
  ISNULL(ap.is_submitted_2yr, 0) AS is_submitted_2yr,
  ISNULL(ap.is_submitted_cte, 0) AS is_submitted_cte,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () AS current_academic_year
FROM
  gabby.alumni.ktc_roster c
  LEFT JOIN gabby.alumni.enrollment_identifiers e ON c.sf_contact_id = e.student_c
  LEFT JOIN gabby.alumni.contact_note_rollup cn ON c.sf_contact_id = cn.contact_id
  AND cn.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  LEFT JOIN app_rollup ap ON c.sf_contact_id = ap.sf_contact_id
