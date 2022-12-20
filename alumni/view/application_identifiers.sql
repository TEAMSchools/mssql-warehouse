CREATE OR ALTER VIEW
  alumni.application_identifiers AS
SELECT
  sub.sf_contact_id,
  sub.application_id,
  sub.school_id,
  sub.match_type,
  sub.application_admission_type,
  sub.application_submission_status,
  sub.starting_application_status,
  sub.application_status,
  sub.honors_special_program_name,
  sub.honors_special_program_status,
  sub.matriculation_decision,
  sub.primary_reason_for_not_attending,
  sub.financial_aid_eligibility,
  sub.unmet_need,
  sub.efc_from_fafsa,
  sub.transfer_application,
  sub.created_date,
  sub.type_for_roll_ups,
  sub.application_name,
  sub.application_account_type,
  sub.application_enrollment_status,
  sub.application_pursuing_degree_type,
  sub.enrollment_start_date,
  CASE
    WHEN sub.type_for_roll_ups = 'College'
    AND sub.application_account_type LIKE '%4 yr' THEN 1
    ELSE 0
  END AS is_4yr_college,
  CASE
    WHEN sub.type_for_roll_ups = 'College'
    AND sub.application_account_type LIKE '%2 yr' THEN 1
    ELSE 0
  END AS is_2yr_college,
  CASE
    WHEN sub.type_for_roll_ups = 'Alternative Program' THEN 1
    ELSE 0
  END AS is_cte,
  CASE
    WHEN sub.application_admission_type = 'Early Action' THEN 1
    ELSE 0
  END AS is_early_action,
  CASE
    WHEN sub.application_admission_type = 'Early Decision' THEN 1
    ELSE 0
  END AS is_early_decision,
  CASE
    WHEN sub.application_admission_type IN (
      'Early Action',
      'Early Decision'
    ) THEN 1
    ELSE 0
  END AS is_early_actiondecision,
  CASE
    WHEN sub.application_submission_status = 'Submitted' THEN 1
    ELSE 0
  END AS is_submitted,
  CASE
    WHEN sub.application_status = 'Accepted' THEN 1
    ELSE 0
  END AS is_accepted,
  CASE
    WHEN sub.match_type IN (
      'Likely Plus',
      'Target',
      'Reach'
    ) THEN 1
    ELSE 0
  END AS is_ltr,
  CASE
    WHEN sub.starting_application_status = 'Wishlist' THEN 1
    ELSE 0
  END AS is_wishlist,
  CASE
    WHEN sub.honors_special_program_name = 'EOF'
    AND sub.honors_special_program_status IN ('Applied', 'Accepted') THEN 1
    ELSE 0
  END AS is_eof_applied,
  CASE
    WHEN sub.honors_special_program_name = 'EOF'
    AND sub.honors_special_program_status = 'Accepted' THEN 1
    ELSE 0
  END AS is_eof_accepted
FROM
  (
    SELECT
      app.applicant_c AS sf_contact_id,
      app.id AS application_id,
      app.school_c AS school_id,
      app.match_type_c AS match_type,
      app.application_admission_type_c AS application_admission_type,
      app.application_submission_status_c AS application_submission_status,
      app.application_status_c AS application_status,
      app.honors_special_program_name_c AS honors_special_program_name,
      app.honors_special_program_status_c AS honors_special_program_status,
      app.matriculation_decision_c AS matriculation_decision,
      app.primary_reason_for_not_attending_c AS primary_reason_for_not_attending,
      app.financial_aid_eligibility_c AS financial_aid_eligibility,
      app.unmet_need_c AS unmet_need,
      app.efc_from_fafsa_c AS efc_from_fafsa,
      app.transfer_application_c AS transfer_application,
      app.created_date,
      app.type_for_roll_ups_c AS type_for_roll_ups,
      acc.[name] AS application_name,
      acc.[type] AS application_account_type,
      enr.status_c AS application_enrollment_status,
      enr.pursuing_degree_type_c AS application_pursuing_degree_type,
      enr.start_date_c AS enrollment_start_date,
      COALESCE(
        app.starting_application_status_c,
        app.application_status_c
      ) AS starting_application_status
    FROM
      gabby.alumni.application_c AS app
      INNER JOIN gabby.alumni.account AS acc ON app.school_c = acc.id
      AND acc.is_deleted = 0
      INNER JOIN gabby.alumni.contact AS c ON app.applicant_c = c.id
      LEFT JOIN gabby.alumni.enrollment_c AS enr ON app.applicant_c = enr.student_c
      AND app.school_c = enr.school_c
      AND c.kipp_hs_class_c = YEAR(enr.start_date_c)
      AND enr.is_deleted = 0
    WHERE
      app.is_deleted = 0
  ) AS sub
