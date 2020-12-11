USE gabby
GO

CREATE OR ALTER VIEW extracts.idauto_staff_roster AS

SELECT QUOTENAME(ISNULL(NULL, ''), '"') AS ["Preferred Name"]
      ,QUOTENAME(ISNULL(df.legal_entity_name, ''), '"') AS ["Company Code"]
      ,QUOTENAME(ISNULL(df.primary_on_site_department, ''), '"') AS ["Home Department Description"]
      ,QUOTENAME(ISNULL(df.primary_site_entity, ''), '"') AS ["Location Description"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, df.manager_df_employee_number), ''), '"') AS ["Business Unit Code"]
      ,QUOTENAME(ISNULL(df.primary_on_site_department, ''), '"') AS ["Business Unit Description"]
      ,QUOTENAME(ISNULL(df.preferred_first_name, ''), '"') AS ["First Name"]
      ,QUOTENAME(ISNULL(df.preferred_last_name, ''), '"') AS ["Last Name"]
      ,QUOTENAME(ISNULL(df.df_employee_number, ''), '"') AS ["Position ID"]
      ,QUOTENAME(ISNULL(df.primary_job, ''), '"') AS ["Job Title Description"]
      ,QUOTENAME(ISNULL(df.[status], ''), '"') AS ["Position Status"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, (CONVERT(DATE, df.rehire_date)),101), ''), '"') AS ["Rehire Date"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, (CONVERT(DATE, df.termination_date)),101), ''), '"') AS ["Termination Date"]
      ,QUOTENAME(ISNULL(CONVERT(VARCHAR, (CONVERT(DATE, df.birth_date)),101), ''), '"') AS ["Birth Date"]
      ,QUOTENAME(ISNULL(COALESCE(df.adp_associate_id, CONVERT(VARCHAR, df.df_employee_number)), ''), '"') AS ["Associate ID"] 
FROM gabby.people.staff_crosswalk_static df
WHERE df.original_hire_date <= DATEADD(DAY, 30, GETDATE())
