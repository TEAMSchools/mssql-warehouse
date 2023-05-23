CREATE OR ALTER VIEW
  extracts.gsheets_collab_transition AS
SELECT
  sf_contact_id,
  last_name,
  first_name,
  application_id,
  application_name,
  matriculation_decision,
  [CCDM Complete],
  CAST(
    expected_hs_graduation_date AS NVARCHAR
  ) AS expected_hs_graduation_date,
  college_match_display_gpa,
  highest_act_score,
  application_account_type,
  currently_enrolled_school,
  competitiveness_ranking_c,
  x_6_yr_minority_completion_rate_c,
  gpa_higher_than_3,
  minor_grad_rate_under50,
  gpa_between_25_29,
  minor_grad_rate_under40,
  undermatch_3gpa,
  undermatch_25_29gpa
FROM
  (
    SELECT
      kt.sf_contact_id,
      kt.last_name,
      kt.first_name,
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
      kt.expected_hs_graduation_date,
      kt.college_match_display_gpa,
      kt.highest_act_score,
      ap.application_account_type,
      kt.currently_enrolled_school,
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
      END AS undermatch_25_29gpa
    FROM
      alumni.ktc_roster AS kt
      LEFT JOIN alumni.application_identifiers AS ap ON (
        kt.sf_contact_id = ap.sf_contact_id
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
      ap.matriculation_decision = 'Matriculated (Intent to Enroll)'
  ) AS sub
