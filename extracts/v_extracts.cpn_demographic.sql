USE gabby
GO

CREATE OR ALTER VIEW extracts.cpn_demographic AS

SELECT state_studentnumber AS [State IDNumber]
      ,student_number AS [Student ID]
      ,first_name AS [First Name]
      ,middle_name AS [Middle Name]
      ,last_name AS [Last Name]
      ,dob AS [Date Of Birth]
      ,schoolid AS [School Code]
      ,school_name AS [Current School Name]
      ,gender AS [Gender]
      ,grade_level AS [Grade Level]
      ,ethnicity AS [Ethnicity Primary]
      ,NULL AS [Family Code]
      ,street AS [Street Address]
      ,city AS [City]
      ,state AS [State]
      ,zip AS [Zip]
      ,NULL AS [Homeless]
      ,CASE WHEN lep_status = 1 THEN 'Y' ELSE 'N' END AS [ESL Student]
      ,CASE WHEN iep_status = 'No IEP' THEN 'N' ELSE 'Y' END AS [Has Active IEP]
      ,CASE WHEN lunchstatus = 'P' THEN 'N' ELSE 'Y' END AS [Low Income]
      ,team AS [Homeroom]
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND rn_year = 1
  AND region = 'KCNA'