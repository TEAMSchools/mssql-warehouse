CREATE OR ALTER VIEW
  extracts.gsheets_collab_roster AS
WITH
  transition AS (
    SELECT
      c.id AS [Salesforce ID],
      c.school_specific_id_c AS [SIS ID],
      u.name AS [College Counselor],
      c.first_name AS [First Name],
      c.last_name AS [Last Name],
      c.currently_enrolled_school_c AS [Current Enrolled High School],
      c.mobile_phone AS [Student Cell Phone],
      CASE
        WHEN co.enroll_status = 0 THEN COALESCE(
          c.email,
          co.student_web_id + '@teamstudents.org'
        )
        ELSE c.email
      END AS [Personal Email Address],
      CASE
        WHEN kt.ktc_status LIKE 'TAF%' THEN NULL
        ELSE sc.contact_1_name
      END AS [Primary Parent Name],
      CASE
        WHEN kt.ktc_status LIKE 'TAF%' THEN kt.sf_home_phone
        ELSE sc.contact_1_phone_mobile
      END AS [Primary Parent Cell Phone],
      sc.contact_1_phone_primary AS [Primary Phone],
      CASE
        WHEN kt.ktc_status LIKE 'TAF%' THEN c.secondary_email_c
        ELSE sc.contact_1_email_current
      END AS [Primary Parent Email],
      CASE
        WHEN kt.ktc_status LIKE 'TAF%' THEN (
          -- trunk-ignore(sqlfluff/LT05)
          c.mailing_street + ' ' + c.mailing_city + ', ' + c.mailing_state + ' ' + c.mailing_postal_code
        )
        ELSE co.street + ' ' + co.city + ', ' + co.[state] + ' ' + co.zip
      END AS [Mailing Address],
      CASE
        WHEN c.most_recent_iep_date_c IS NOT NULL THEN 1
      END AS [IEP],
      co.c_504_status AS [504 Plan],
      c.df_has_fafsa_c AS [FAFSA Complete],
      CASE
        WHEN c.latest_state_financial_aid_app_date_c IS NOT NULL THEN 'Yes'
        ELSE 'No'
      END AS [HESAA Complete],
      c.efc_from_fafsa_c AS [EFC Actual],
      CAST(
        c.expected_hs_graduation_c AS NVARCHAR
      ) AS expected_hs_grad_date,
      kt.college_match_display_gpa,
      kt.highest_act_score,
      ap.application_id,
      ap.application_name,
      ap.matriculation_decision,
      CASE
        WHEN cn.subject_c IS NULL THEN 'No'
        ELSE 'Yes'
      END AS 'CCDM Complete',
      COUNT(*) OVER (
        PARTITION BY
          ap.sf_contact_id
        ORDER BY
          ap.application_id ASC
      ) AS row_count,
      ap.application_account_type,
      ac.competitiveness_ranking_c,
      ac.x_6_yr_minority_completion_rate_c,
      CASE
        WHEN kt.college_match_display_gpa >= 3.0 THEN 1
        ELSE 0
      END AS gpa_higher_than_3,
      CASE
        WHEN ac.x_6_yr_minority_completion_rate_c < 50 THEN 1
        ELSE 0
      END AS minor_grad_rate_under50,
      CASE
        WHEN (
          kt.college_match_display_gpa BETWEEN 2.5 AND 2.9
        ) THEN 1
        ELSE 0
      END AS gpa_between_25_29,
      CASE
        WHEN ac.x_6_yr_minority_completion_rate_c < 40 THEN 1
        ELSE 0
      END AS minor_grad_rate_under40,
      CASE
        WHEN (
          kt.college_match_display_gpa >= 3.0
          AND ac.x_6_yr_minority_completion_rate_c < 50
        ) THEN 1
        ELSE 0
      END AS undermatch_3gpa,
      CASE
        WHEN (
          (
            kt.college_match_display_gpa BETWEEN 2.5 AND 2.9
          )
          AND ac.x_6_yr_minority_completion_rate_c < 40
        ) THEN 1
        ELSE 0
      END AS undermatch_25_29gpa,
      ROW_NUMBER() OVER (
        PARTITION BY
          c.id
        ORDER BY
          cn.date_c DESC
      ) AS rn_ccdm
    FROM
      alumni.contact AS c
      LEFT JOIN alumni.[user] AS u ON c.owner_id = u.id
      LEFT JOIN powerschool.student_contacts_wide_static AS sc ON (
        CAST(sc.student_number AS NVARCHAR) = CAST(
          c.school_specific_id_c AS NVARCHAR
        )
      )
      LEFT JOIN powerschool.cohort_identifiers_static AS co ON (
        CAST(co.student_number AS NVARCHAR) = CAST(
          c.school_specific_id_c AS NVARCHAR
        )
        AND co.rn_undergrad = 1
      )
      LEFT JOIN gabby.alumni.ktc_roster AS kt ON kt.sf_contact_id = c.id
      LEFT JOIN gabby.alumni.application_identifiers AS ap ON (
        kt.sf_contact_id = ap.sf_contact_id
        AND ap.matriculation_decision = 'Matriculated (Intent to Enroll)'
      )
      LEFT JOIN alumni.contact_note_c AS cn ON (
        kt.sf_contact_id = cn.contact_c
        AND cn.subject_c = 'CCDM'
        AND cn.is_deleted = 0
      )
      -- trunk-ignore(sqlfluff/LT05)
      LEFT JOIN gabby.alumni.enrollment_identifiers AS ei ON (ei.student_c = kt.sf_contact_id)
      LEFT JOIN gabby.alumni.account AS ac ON ac.ncesid_c = ei.ugrad_ncesid
    WHERE
      c.is_deleted = 0
  )
SELECT
  t.[Salesforce ID],
  t.[SIS ID],
  t.[College Counselor],
  t.[First Name],
  t.[Last Name],
  t.[Current Enrolled High School],
  t.[Student Cell Phone],
  t.[Personal Email Address],
  t.[Primary Parent Name],
  t.[Primary Parent Cell Phone],
  t.[Primary Parent Email],
  t.[Mailing Address],
  t.[IEP],
  t.[504 Plan],
  t.[FAFSA Complete],
  t.[HESAA Complete],
  t.[EFC Actual],
  t.expected_hs_grad_date,
  t.college_match_display_gpa,
  t.highest_act_score,
  t.application_id,
  t.application_name,
  t.matriculation_decision,
  t.[CCDM Complete],
  t.gpa_higher_than_3,
  t.minor_grad_rate_under50,
  t.gpa_between_25_29,
  t.minor_grad_rate_under40,
  t.undermatch_3gpa,
  t.undermatch_25_29gpa
FROM
  transition AS t
WHERE
  t.rn_ccdm = 1
