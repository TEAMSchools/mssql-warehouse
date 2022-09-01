USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_kfwd_contacts AS

SELECT ktc.currently_enrolled_school AS [Currently Enrolled School]
      ,ktc.last_name AS [Last Name]
      ,ktc.first_name AS [First Name]
      ,ktc.sf_contact_id AS [Salesforce ID]
      ,CONVERT(VARCHAR, s.dob, 101) AS [Birthdate]
      ,ktc.ktc_cohort AS [HS Cohort]
      ,c.reason AS [Subject]
      ,CASE
        WHEN c.call_type = 'P' OR c.call_type = 'VC' THEN 'Call'
        WHEN c.call_type = 'IP' THEN 'In Person'
        WHEN c.call_type = 'SMS' THEN 'Text'
        WHEN c.call_type = 'E' THEN 'Email'
        WHEN c.call_type = 'L' THEN 'Mail (Letter/Postcard)'
        ELSE NULL
       END AS [Type]
      ,CONVERT(VARCHAR, c.call_date_time, 101) AS [Contact Date]
      ,CASE WHEN c.call_status = 'Completed' THEN 'Successful' ELSE 'Outreach' END AS [Status]
      ,NULL AS [Category]
      ,NULL AS [Current Category Ranking]
      ,c.call_topic AS [Comments]
      ,c.dlcall_log_id
FROM gabby.alumni.ktc_roster ktc
LEFT JOIN gabby.powerschool.students s
  ON ktc.student_number = s.student_number
INNER JOIN gabby.deanslist.communication c
  ON c.student_school_id = ktc.student_number
 AND c.reason LIKE 'KF:%'