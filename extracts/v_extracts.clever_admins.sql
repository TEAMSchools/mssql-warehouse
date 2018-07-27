USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_admins AS

SELECT DISTINCT 
       CONVERT(VARCHAR(25),t.schoolid) AS [School_id]
      ,COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [Staff_id]      
      ,ad.userprincipalname AS [Admin_email]
      ,df.preferred_first_name AS [First_name]      
      ,df.preferred_last_name AS [Last_name]
      ,'School Admin' AS [Admin_title]
      ,ad.samaccountname AS [Username]
      ,NULL AS [Password]
      ,NULL AS [Role]
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.adsi.user_attributes_static ad
  ON df.df_employee_number = ad.employeenumber
 AND ISNUMERIC(ad.employeenumber) = 1
LEFT JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
JOIN gabby.powerschool.teachers_static t
  ON id.ps_teachernumber = t.teachernumber COLLATE Latin1_General_BIN
 AND t.status = 1
 AND t.schoolid != 0
WHERE df.primary_on_site_department != 'Data'