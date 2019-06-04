USE gabby
GO

CREATE OR ALTER VIEW extracts.renlearn_teachers AS

SELECT COALESCE(psid.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS id
      ,COALESCE(psid.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS teachernumber
      ,df.primary_site_schoolid AS schoolid
      ,df.preferred_last_name AS last_name
      ,df.preferred_first_name AS first_name
      ,NULL AS middle_name
      ,ad.samaccountname AS teacherloginid
      ,ad.userprincipalname AS staff_email
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.people.id_crosswalk_powerschool psid
  ON df.df_employee_number = psid.df_employee_number
 AND psid.is_master = 1
LEFT JOIN gabby.adsi.user_attributes_static ad
  ON CONVERT(VARCHAR(25),df.df_employee_number) = ad.employeenumber
WHERE status != 'TERMINATED'
  AND legal_entity_name != 'KIPP Miami'
  AND primary_site_schoolid != 0