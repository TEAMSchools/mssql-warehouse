USE gabby;
GO

CREATE OR ALTER VIEW extracts.renlearn_students AS

SELECT student_number AS id
      ,student_number
      ,first_name
      ,last_name
      ,middle_name
      ,CASE WHEN gender = 'false' THEN 'F' ELSE gender END AS gender
      ,grade_level
      ,CASE WHEN ethnicity = 'true' THEN 'T' ELSE ethnicity END AS ethnicity
      ,dob
      ,enroll_status
      ,exitcode
      ,exitdate
      ,state_studentnumber
      ,student_web_id + '@apps.teamschools.org' AS student_email
FROM gabby.powerschool.students
WHERE enroll_status = 0
  AND db_name != 'kippmiami';