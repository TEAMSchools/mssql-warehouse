USE gabby;
GO

CREATE OR ALTER VIEW extracts.illuminate_student_portal_accounts AS

SELECT student_number AS [01 Student ID]
      ,student_web_id AS [02 Username]
      ,student_web_id + '@teamstudents.org' AS [03 Email]
      ,1 AS [04 Enable portal]
      ,student_web_password AS [05 Temporary password]
FROM gabby.powerschool.student_access_accounts_static
WHERE enroll_status = 0
