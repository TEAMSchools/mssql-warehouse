USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_student_roster AS

SELECT co.studentid 
      ,co.student_number 
      ,co.lastfirst 
      ,co.schoolid 
      ,co.school_name 
      ,co.grade_level 
      ,co.team 
      ,co.iep_status
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1 
  AND co.schoolid != 999999 