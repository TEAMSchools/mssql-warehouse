CREATE OR ALTER VIEW
  extracts.gsheets_collab_roster AS
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
  sc.contact_1_name AS [Primary Parent Name],
  sc.contact_1_phone_mobile AS [Primary Parent Cell Phone],
  sc.contact_1_phone_primary AS [Primary Phone],
  sc.contact_1_email_current AS [Primary Parent Email],
  co.street + ' ' + co.city + ', ' + co.[state] + ' ' + co.zip AS [Mailing Address],
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
  c.expected_hs_graduation_c
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
