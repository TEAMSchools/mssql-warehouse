USE gabby;

GO
CREATE OR ALTER VIEW
  extracts.clever_teachers AS
SELECT
  df.primary_site_schoolid AS [School_id],
  df.ps_teachernumber AS [Teacher_id],
  df.ps_teachernumber AS [Teacher_number],
  CAST(df.df_employee_number AS VARCHAR(25)) AS [State_teacher_id],
  df.userprincipalname AS [Teacher_email],
  df.preferred_first_name AS [First_name],
  NULL AS [Middle_name],
  df.preferred_last_name AS [Last_name],
  df.primary_job AS [Title],
  df.samaccountname AS [Username],
  NULL AS [Password]
FROM
  gabby.people.staff_crosswalk_static AS df
WHERE
  df.is_active_ad = 1
  AND df.[status] <> 'PRESTART'
  AND df.primary_site_schoolid IS NOT NULL
  AND df.df_employee_number IS NOT NULL
