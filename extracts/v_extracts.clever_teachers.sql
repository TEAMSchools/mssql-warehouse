USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_teachers AS

SELECT CONVERT(VARCHAR(25),df.primary_site_schoolid) AS [School_id]
      ,COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [Teacher_id]
      ,COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [Teacher_number]
      ,CONVERT(VARCHAR(25),df.df_employee_number) AS [State_teacher_id]
      ,ad.userprincipalname AS [Teacher_email]
      ,df.preferred_first_name AS [First_name]
      ,NULL AS [Middle_name]
      ,df.preferred_last_name AS [Last_name]
      ,df.position_title AS [Title]
      ,ad.samaccountname AS [Username]
      ,NULL AS [Password]
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.adsi.user_attributes_static ad
  ON df.df_employee_number = ad.employeenumber
 AND ISNUMERIC(ad.employeenumber) = 1
LEFT JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
WHERE df.primary_site_schoolid != 0;