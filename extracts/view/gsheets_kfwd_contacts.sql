CREATE OR ALTER VIEW
  extracts.gsheets_kfwd_contacts AS
SELECT
  ktc.currently_enrolled_school AS [Currently Enrolled School],
  ktc.last_name AS [Last Name],
  ktc.first_name AS [First Name],
  ktc.sf_contact_id AS [Salesforce ID],
  ktc.ktc_cohort AS [HS Cohort],
  CONVERT(VARCHAR, s.dob, 101) AS [Birthdate],
  c.reason AS [Subject],
  c.call_topic AS [Comments],
  c.response AS [Next Steps],
  c.dlcall_log_id,
  CONVERT(VARCHAR, c.call_date_time, 101) AS [Contact Date],
  CASE
    WHEN c.call_status = 'Completed' THEN 'Successful'
    ELSE 'Outreach'
  END AS [Status],
  CASE
    WHEN (
      c.call_type = 'P'
      OR c.call_type = 'VC'
    ) THEN 'Call'
    WHEN c.call_type = 'IP' THEN 'In Person'
    WHEN c.call_type = 'SMS' THEN 'Text'
    WHEN c.call_type = 'E' THEN 'Email'
    WHEN c.call_type = 'L' THEN 'Mail (Letter/Postcard)'
  END AS [Type],
  NULL AS [Category],
  NULL AS [Current Category Ranking]
FROM
  gabby.alumni.ktc_roster AS ktc
  INNER JOIN gabby.powerschool.students AS s ON (
    ktc.student_number = s.student_number
  )
  INNER JOIN gabby.deanslist.communication AS c ON (
    c.student_school_id = ktc.student_number
    AND c.reason LIKE 'KF:%'
  )
