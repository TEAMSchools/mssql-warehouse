USE gabby;
GO

CREATE OR ALTER VIEW extracts.renlearn_students AS

SELECT student_number AS id
      ,student_number
      ,first_name
      ,last_name
      ,middle_name
      ,gender
      ,grade_level
      ,ethnicity
      ,dob
      ,enroll_status
      ,exitcode
      ,exitdate
      ,state_studentnumber
      ,student_web_id + '@teamstudents.org' AS student_email
FROM gabby.powerschool.students
WHERE enroll_status = 0
  AND grade_level >= 2