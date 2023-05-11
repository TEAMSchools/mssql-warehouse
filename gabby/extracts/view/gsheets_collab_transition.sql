CREATE OR ALTER VIEW
  extracts.gsheets_collab_transition AS
SELECT
  sub.sf_contact_id,
  sub.last_name,
  sub.first_name,
  sub.application_id,
  sub.application_name,
  sub.matriculation_decision,
  sub.[CCDM Complete],
  CAST(
    sub.expected_hs_graduation_date AS NVARCHAR
  ) AS expected_hs_graduation_date
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
      kt.expected_hs_graduation_date
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
    WHERE
      ap.matriculation_decision = 'Matriculated (Intent to Enroll)'
      AND ap.application_enrollment_status = 'Matriculated'
  ) AS sub
