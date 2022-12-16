CREATE OR ALTER VIEW
  tableau.ktc_outcomes_dashboard AS
WITH
  matric_app AS (
    SELECT
      c.id AS contact_id,
      acc.[name] AS matriculation_school_name,
      acc.[type] AS matriculation_account_type,
      enr.status_c AS matriculation_enrollment_status,
      enr.pursuing_degree_type_c AS matriculation_pursuing_degree_type,
      ROW_NUMBER() OVER (
        PARTITION BY
          c.id
        ORDER BY
          enr.start_date_c
      ) AS rn
    FROM
      gabby.alumni.contact AS c
      INNER JOIN gabby.alumni.application_c AS app ON c.id = app.applicant_c
      AND app.is_deleted = 0
      AND app.transfer_application_c = 0
      AND app.matriculation_decision_c = 'Matriculated (Intent to Enroll)'
      INNER JOIN gabby.alumni.account AS acc ON app.school_c = acc.id
      AND acc.is_deleted = 0
      INNER JOIN gabby.alumni.enrollment_c AS enr ON app.applicant_c = enr.student_c
      AND app.school_c = enr.school_c
      AND c.kipp_hs_class_c = YEAR(enr.start_date_c)
      AND enr.is_deleted = 0
    WHERE
      c.is_deleted = 0
  )
SELECT
  c.sf_contact_id AS contact_id,
  c.lastfirst AS [name],
  c.ktc_cohort AS kipp_hs_class_c,
  c.is_kipp_ms_graduate AS kipp_ms_graduate_c,
  c.is_kipp_hs_graduate AS kipp_hs_graduate_c,
  c.expected_hs_graduation_date AS expected_hs_graduation_c,
  c.actual_hs_graduation_date AS actual_hs_graduation_date_c,
  c.expected_college_graduation_date AS expected_college_graduation_c,
  c.actual_college_graduation_date AS actual_college_graduation_date_c,
  c.current_kipp_student AS current_kipp_student_c,
  c.highest_act_score AS highest_act_score_c,
  c.record_type_name AS record_type_name,
  c.counselor_name AS [user_name],
  c.college_match_display_gpa,
  c.kipp_region_name,
  c.kipp_region_school,
  c.post_hs_simple_admin,
  c.ktc_status,
  c.currently_enrolled_school,
  ei.ugrad_account_name AS ugrad_school_name,
  ei.ugrad_pursuing_degree_type,
  ei.ugrad_status,
  ei.ugrad_start_date,
  ei.ugrad_actual_end_date,
  ei.ugrad_anticipated_graduation,
  ei.ugrad_credits_required_for_graduation,
  ei.ecc_account_name AS ecc_school_name,
  ei.ecc_pursuing_degree_type,
  ei.ecc_status,
  ei.ecc_start_date,
  ei.ecc_actual_end_date,
  ei.ecc_anticipated_graduation,
  ei.ecc_adjusted_6_year_minority_graduation_rate,
  ei.ecc_account_type,
  ei.ecc_credits_required_for_graduation,
  ei.hs_account_name AS hs_school_name,
  ei.hs_pursuing_degree_type,
  ei.hs_status,
  ei.hs_start_date,
  ei.hs_actual_end_date,
  ei.hs_anticipated_graduation,
  ei.hs_credits_required_for_graduation,
  ei.aa_account_name AS aa_school_name,
  ei.aa_pursuing_degree_type,
  ei.aa_status,
  ei.aa_start_date,
  ei.aa_actual_end_date,
  ei.aa_anticipated_graduation,
  ei.aa_credits_required_for_graduation,
  a.matriculation_school_name,
  a.matriculation_account_type,
  a.matriculation_enrollment_status,
  a.matriculation_pursuing_degree_type
FROM
  gabby.alumni.ktc_roster AS c
  LEFT JOIN gabby.alumni.enrollment_identifiers AS ei ON c.sf_contact_id = ei.student_c
  LEFT JOIN matric_app AS a ON c.sf_contact_id = a.contact_id
  AND a.rn = 1
WHERE
  c.sf_contact_id IS NOT NULL
