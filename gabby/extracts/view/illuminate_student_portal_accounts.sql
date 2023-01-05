CREATE OR ALTER VIEW
  extracts.illuminate_student_portal_accounts AS
SELECT
  s.student_number AS [01 Student ID],
  saa.student_web_id AS [02 Username],
  saa.student_web_id + '@teamstudents.org' AS [03 Email],
  1 AS [04 Enable portal],
  saa.student_web_password AS [05 Temporary password]
FROM
  powerschool.students AS s
  INNER JOIN powerschool.student_access_accounts_static AS saa ON (
    s.student_number = saa.student_number
  )
WHERE
  s.enroll_status = 0
