USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_admins AS

SELECT CONVERT(VARCHAR(25),df.primary_site_schoolid) AS [School_id]
       --CONVERT(VARCHAR(25),sch.school_number) AS [School_id]
      ,COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [Staff_id]      
      ,ad.userprincipalname AS [Admin_email]
      ,df.preferred_first_name AS [First_name]      
      ,df.preferred_last_name AS [Last_name]
      ,'School Admin' AS [Admin_title]
      ,ad.samaccountname AS [Username]
      ,NULL AS [Password]
      ,NULL AS [Role]
FROM gabby.dayforce.staff_roster df
JOIN gabby.adsi.user_attributes_static ad
  ON CONVERT(VARCHAR(25),df.df_employee_number) = ad.employeenumber
JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
--JOIN gabby.powerschool.schools sch
--  ON CASE 
--      WHEN df.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
--      WHEN df.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
--      WHEN df.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
--      WHEN df.legal_entity_name = 'KIPP New Jersey' THEN sch.db_name
--     END = sch.db_name
-- AND sch.state_excludefromreporting = 0
WHERE df.primary_on_site_department != 'Data'
  AND df.primary_site_schoolid != 0