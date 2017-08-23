USE gabby
GO

ALTER VIEW extracts.gsheets_student_logins AS

SELECT co.student_number AS SN 
      ,co.lastfirst AS [Last First] 
      ,co.grade_level AS [Gr] 
      ,co.team
      ,co.school_name AS [School] 
      ,s.student_web_id AS [Core Username] 
      ,s.student_web_password AS [Core Password] 
      ,s.student_web_id + '@teamstudents.org' AS [Google Email] 
      ,co.entrydate AS [Date Enrolled] 
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.student_access_accounts s
  ON co.student_number = s.student_number
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1 
  AND co.enroll_status = 0