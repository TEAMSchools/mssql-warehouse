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
      ,co.state_studentnumber
      ,co.region
      ,co.reporting_schoolid
      ,co.boy_status
      ,co.enroll_status
      ,co.advisor_name
      ,co.student_web_id + '@teamstudents.org' AS student_email
      ,co.is_pathways AS is_self_contained
      ,co.ethnicity
      ,co.lep_status
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1 
  AND co.grade_level <> 99
