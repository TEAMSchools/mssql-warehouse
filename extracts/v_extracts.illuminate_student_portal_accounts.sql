USE gabby;
GO

CREATE OR ALTER VIEW extracts.illuminate_student_portal_accounts AS

SELECT student_number AS [01 Student ID]
      ,student_web_id AS [02 Username]
      ,student_web_id + '@teamstudents.org' AS [03 Email]
      ,CASE WHEN enroll_status = 0 THEN 1 ELSE 0 END AS [04 Enable portal]
      ,student_web_password AS [05 Temporary password]
FROM gabby.powerschool.student_access_accounts_static
WHERE student_number IN (SELECT student_number FROM gabby.powerschool.students WHERE enroll_status = 0)