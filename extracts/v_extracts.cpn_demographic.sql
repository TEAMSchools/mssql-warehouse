USE gabby
GO

CREATE OR ALTER VIEW extracts.cpn_demographic AS

SELECT co.state_studentnumber AS [State IDNumber]
      ,co.student_number AS [Student ID]
      ,co.first_name AS [First Name]
      ,co.middle_name AS [Middle Name]
      ,co.last_name AS [Last Name]
      ,co.dob AS [Date Of Birth]
      ,co.schoolid AS [School Code]
      ,co.school_name AS [Current School Name]
      ,co.gender AS [Gender]
      ,co.grade_level AS [Grade Level]
      ,co.ethnicity AS [Ethnicity Primary]
      ,s.family_ident AS [Family Code]
      ,co.street AS [Street Address]
      ,co.city AS [City]
      ,co.state AS [State]
      ,co.zip AS [Zip]
      ,CASE WHEN scf.homeless_code IS NOT NULL THEN 'Y' ELSE 'N' END AS [Homeless]
      ,CASE WHEN co.lep_status = 1 THEN 'Y' ELSE 'N' END AS [ESL Student]
      ,CASE WHEN co.iep_status = 'No IEP' THEN 'N' ELSE 'Y' END AS [Has Active IEP]
      ,CASE WHEN co.lunchstatus = 'P' THEN 'N' ELSE 'Y' END AS [Low Income]
      ,co.team AS [Homeroom]
      ,co.entrydate AS [Most-Recent Entry Date]
      ,co.exitdate AS [Most-Recent Exit Date]
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.studentcorefields scf
  ON co.students_dcid = scf.studentsdcid
LEFT JOIN gabby.powerschool.students s
  ON co.studentid = s.id
WHERE co.rn_year = 1
  AND co.region = 'KCNA'