USE gabby
GO

CREATE OR ALTER VIEW extracts.idauto_staff_roster AS

SELECT QUOTENAME(ISNULL(preferred_name, ''), '"') AS ["Preferred Name"]
      ,QUOTENAME(ISNULL(payroll_company_code, ''), '"') AS ["Company Code"]
      ,QUOTENAME(ISNULL(subject_dept_custom, ''), '"') AS ["Home Department Description"]
      ,QUOTENAME(ISNULL(location_description, ''), '"') AS ["Location Description"]
      ,QUOTENAME(ISNULL(NULL, ''), '"') AS ["Business Unit Code"]
      ,QUOTENAME(ISNULL(subject_dept_custom, ''), '"') AS ["Business Unit Description"]
      ,QUOTENAME(ISNULL(first_name, ''), '"') AS ["First Name"]
      ,QUOTENAME(ISNULL(last_name, ''), '"') AS ["Last Name"]
      ,QUOTENAME(ISNULL(position_id, ''), '"') AS ["Position ID"]
      ,QUOTENAME(ISNULL(COALESCE(job_title_custom, job_title_description), ''), '"') AS ["Job Title Description"]
      ,QUOTENAME(ISNULL(position_status, ''), '"') AS ["Position Status"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR,(CONVERT(DATE,rehire_date,101)),101), ''), '"') AS ["Rehire Date"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR,(CONVERT(DATE,termination_date,101)),101), ''), '"') AS ["Termination Date"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR,(CONVERT(DATE,birth_date,101)),101), ''), '"') AS ["Birth Date"]
      ,QUOTENAME(ISNULL(associate_id, ''), '"') AS ["Associate ID"] 
FROM gabby.adp.staff_roster
WHERE rn_curr = 1