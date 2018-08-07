USE gabby;
GO

CREATE OR ALTER VIEW extracts.renlearn_studentsunpw AS 

SELECT co.student_number AS id
      ,co.student_number
      ,co.student_web_id
      ,co.student_web_password
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.enroll_status = 0
  AND co.db_name != 'kippmiami';