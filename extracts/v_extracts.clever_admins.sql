USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_admins AS

WITH campus AS (
  SELECT '18th Ave Campus' AS primary_site
        ,73255 AS schoolid
  UNION
  SELECT '18th Ave Campus' AS primary_site
        ,73258 AS schoolid
  UNION
  SELECT 'KIPP Lanning Sq Campus' AS primary_site
        ,179901 AS schoolid
  UNION
  SELECT 'KIPP Lanning Sq Campus' AS primary_site
        ,179902 AS schoolid
  UNION
  SELECT 'Room 10 - 740 Chestnut St' AS primary_site
        ,179902 AS schoolid
  UNION
  SELECT 'Room 10 - 740 Chestnut St' AS primary_site
        ,179901 AS schoolid
  UNION
  SELECT 'Room 11 - 6745 NW 23rd Ave' AS primary_site
        ,30200801 AS schoolid
 )

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
WHERE df.status != 'TERMINATED'
  AND df.primary_on_site_department != 'Data'
  AND df.primary_site_schoolid != 0
  --AND (df.primary_site_schoolid != 0 OR df.is_campus_staff = 1) /* off until we figure out what school to put these bozos in*/

UNION ALL

SELECT CONVERT(VARCHAR(25),c.schoolid) AS [School_id]
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
JOIN campus c
  ON df.primary_site = c.primary_site
WHERE df.status != 'TERMINATED'
  AND df.primary_on_site_department != 'Data'
  AND df.is_campus_staff = 1