USE gabby
GO

CREATE OR ALTER VIEW extracts.idauto_staff_roster AS

SELECT QUOTENAME(ISNULL(NULL, ''), '"') AS ["Preferred Name"]
      ,QUOTENAME(ISNULL(df.preferred_first_name, ''), '"') AS ["First Name"]
      ,QUOTENAME(ISNULL(df.preferred_last_name, ''), '"') AS ["Last Name"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, (CONVERT(DATE, df.rehire_date)),101), ''), '"') AS ["Rehire Date"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, (CONVERT(DATE, df.termination_date)),101), ''), '"') AS ["Termination Date"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, (CONVERT(DATE, df.birth_date)),101), ''), '"') AS ["Birth Date"]
      ,QUOTENAME(ISNULL(df.business_unit, ''), '"') AS ["Company Code"]
      ,QUOTENAME(ISNULL(df.home_department, ''), '"') AS ["Home Department Description"]
      ,QUOTENAME(ISNULL(df.[location], ''), '"') AS ["Location Description"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, df.manager_employee_number), ''), '"') AS ["Business Unit Code"]
      ,QUOTENAME(ISNULL(df.home_department, ''), '"') AS ["Business Unit Description"]
      ,QUOTENAME(ISNULL(df.employee_number, ''), '"') AS ["Position ID"]
      ,QUOTENAME(ISNULL(df.job_title, ''), '"') AS ["Job Title Description"]
      ,QUOTENAME(ISNULL(CASE WHEN df.position_status = 'Prestart' THEN 'Active' ELSE df.position_status END, ''), '"') AS ["Position Status"]
      ,QUOTENAME(ISNULL(df.associate_id, ''), '"') AS ["Associate ID"]
FROM gabby.people.staff_roster df
WHERE COALESCE(df.rehire_date, df.original_hire_date) <= DATEADD(DAY, 10, GETDATE())
