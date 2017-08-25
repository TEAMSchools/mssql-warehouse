USE gabby
GO

ALTER VIEW extracts.gsheets_student_logins AS

SELECT co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.school_name
      ,CONVERT(NVARCHAR,co.entrydate) AS entrydate

      ,s.student_web_id
      ,s.student_web_password
      ,s.student_web_id + '@teamstudents.org' AS student_email      
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.student_access_accounts s
  ON co.student_number = s.student_number
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1 
  AND co.enroll_status = 0