USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_admins AS

SELECT CONVERT(VARCHAR(25),COALESCE(sch.school_number, df.primary_site_schoolid)) AS [School_id]
      ,COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [Staff_id]      
      ,ad.userprincipalname AS [Admin_email]
      ,df.preferred_first_name AS [First_name]      
      ,df.preferred_last_name AS [Last_name]
      ,'School Admin' AS [Admin_title]
      ,ad.samaccountname AS [Username]
      ,NULL AS [Password]
      ,CASE WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead' END AS [Role]
FROM gabby.dayforce.staff_roster df
JOIN gabby.adsi.user_attributes_static ad
  ON CONVERT(VARCHAR(25),df.df_employee_number) = ad.employeenumber
LEFT JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
LEFT JOIN gabby.powerschool.schools sch
  ON CASE WHEN df.primary_on_site_department = 'Teaching and Learning' THEN sch.db_name END = sch.db_name
 AND sch.state_excludefromreporting = 0
WHERE df.primary_on_site_department != 'Data'
  AND df.primary_site_schoolid != 0
  AND df.status != 'TERMINATED'