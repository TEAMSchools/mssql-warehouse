USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_admins AS

/* School staff assigned to primary school only */
SELECT CONVERT(VARCHAR(25), df.primary_site_schoolid) AS [School_id]
      ,df.ps_teachernumber AS [Staff_id]      
      ,df.userprincipalname AS [Admin_email]
      ,df.preferred_first_name AS [First_name]      
      ,df.preferred_last_name AS [Last_name]
      ,'School Admin' AS [Admin_title]
      ,df.samaccountname AS [Username]
      ,NULL AS [Password]
      ,CASE WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead' END AS [Role]
FROM gabby.people.staff_crosswalk_static df
WHERE df.status != 'TERMINATED'
  AND df.primary_on_site_department NOT IN ('Data', 'Teaching and Learning')
  AND df.is_campus_staff = 0

UNION ALL

/* Campus staff assigned to all schools at campus */
SELECT CONVERT(VARCHAR(25), cc.ps_school_id) AS [School_id]
      ,df.ps_teachernumber AS [Staff_id]      
      ,df.userprincipalname AS [Admin_email]
      ,df.preferred_first_name AS [First_name]      
      ,df.preferred_last_name AS [Last_name]
      ,'School Admin' AS [Admin_title]
      ,df.samaccountname AS [Username]
      ,NULL AS [Password]
      ,CASE WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead' END AS [Role]
FROM gabby.people.staff_crosswalk_static df
JOIN gabby.people.campus_crosswalk cc
  ON df.primary_site = cc.campus_name
 AND cc._fivetran_deleted = 0
 AND cc.is_pathways = 0
WHERE df.status != 'TERMINATED'
  AND df.primary_on_site_department NOT IN ('Data', 'Teaching and Learning')
  AND df.is_campus_staff = 1

UNION ALL

/* T&L to all schools under CMO */
SELECT CONVERT(VARCHAR(25), sch.school_number) AS [School_id]
      ,df.ps_teachernumber AS [Staff_id]
      ,df.userprincipalname AS [Admin_email]
      ,df.preferred_first_name AS [First_name]      
      ,df.preferred_last_name AS [Last_name]
      ,'School Admin' AS [Admin_title]
      ,df.samaccountname AS [Username]
      ,NULL AS [Password]
      ,CASE WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead' END AS [Role]
FROM gabby.people.staff_crosswalk_static df
JOIN gabby.powerschool.schools sch
  ON sch.state_excludefromreporting = 0
WHERE df.status != 'TERMINATED'
  AND df.primary_on_site_department = 'Teaching and Learning'

UNION ALL

SELECT '73253' AS [School_id]
      ,'data_test' AS [Staff_id]
      ,'data_test@kippnj.org' AS [Admin_email]
      ,'Demo_Test' AS [First_name]
      ,'Data_Test' AS [Last_name]
      ,'School Admin' AS [Admin_title]
      ,'data_test' AS [Username]
      ,NULL AS [Password]
      ,'School Tech Lead' AS [Role]