CREATE OR ALTER VIEW
  extracts.gsheets_kippfwd_enrollment_verification AS
WITH
  tier AS (
    SELECT
      contact_c,
      subject_c AS tier,
      utilities.DATE_TO_SY (date_c) AS academic_year,
      ROW_NUMBER() OVER (
        PARTITION BY
          contact_c,
          utilities.DATE_TO_SY (date_c)
        ORDER BY
          date_c DESC
      ) AS rn
    FROM
      alumni.contact_note_c
    WHERE
      is_deleted = 0
      AND subject_c LIKE 'Tier [0-9]'
  )
SELECT
  kr.sf_contact_id,
  CONCAT(kr.first_name, ' ', kr.last_name) AS [Full Name],
  kr.currently_enrolled_school AS [Currently Enrolled School],
  kr.counselor_name AS [Contact Owner],
  kr.ktc_cohort AS [KIPP HS Class],
  CONVERT(
    NVARCHAR,
    ei.ugrad_date_last_verified,
    101
  ) AS [EV Status],
  t.tier AS [Tier]
FROM
  alumni.ktc_roster AS kr
  LEFT JOIN alumni.enrollment_identifiers AS ei ON kr.sf_contact_id = ei.student_c
  LEFT JOIN tier AS t ON (
    t.contact_c = kr.sf_contact_id
    AND t.rn = 1
  )
WHERE
  kr.ktc_status IN ('TAF', 'HSG')
  AND kr.currently_enrolled_school IS NOT NULL
