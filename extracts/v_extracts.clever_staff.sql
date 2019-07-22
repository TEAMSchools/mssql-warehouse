USE gabby;
GO

CREATE OR ALTER VIEW extracts.clever_staff AS

/*
  School staff assigned to primary school only
  Campus staff assigned to all schools at campus
*/
SELECT CONVERT(VARCHAR(25), COALESCE(ccw.ps_school_id, df.primary_site_schoolid)) AS [School_id]
      ,df.ps_teachernumber AS [Staff_id]
      ,df.userprincipalname AS [Staff_email]
      ,df.preferred_first_name AS [First_name]
      ,df.preferred_last_name AS [Last_name]
      ,df.primary_on_site_department AS [Department]
      ,'School Admin' AS [Title]
      ,df.samaccountname AS [Username]
      ,NULL AS [Password]
      ,CASE WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead' END AS [Role]
FROM gabby.people.staff_crosswalk_static df
LEFT JOIN gabby.people.campus_crosswalk ccw
  ON df.primary_site = ccw.campus_name
 AND ccw._fivetran_deleted = 0
 AND ccw.is_pathways = 0
WHERE df.is_active = 1
  AND df.primary_on_site_department NOT IN ('Data', 'Teaching and Learning')
  AND COALESCE(ccw.ps_school_id, df.primary_site_schoolid) != 0

UNION ALL

/* T&L/Data to all schools under CMO */
SELECT CONVERT(VARCHAR(25), sch.school_number) AS [School_id]
      ,df.ps_teachernumber AS [Staff_id]
      ,df.userprincipalname AS [Staff_email]
      ,df.preferred_first_name AS [First_name]
      ,df.preferred_last_name AS [Last_name]
      ,df.primary_on_site_department AS [Department]
      ,'School Admin' AS [Title]
      ,df.samaccountname AS [Username]
      ,NULL AS [Password]
      ,CASE WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead' END AS [Role]
FROM gabby.people.staff_crosswalk_static df
JOIN gabby.powerschool.schools sch
  ON sch.state_excludefromreporting = 0
WHERE df.is_active = 1
  AND df.primary_on_site_department IN ('Data', 'Teaching and Learning')

UNION ALL

SELECT '73253' AS [School_id]
      ,'data_test' AS [Staff_id]
      ,'data_test@kippnj.org' AS [Staff_email]
      ,'Demo_Test' AS [First_name]
      ,'Data_Test' AS [Last_name]
      ,NULL AS [Department]
      ,'School Admin' AS [Title]
      ,'data_test' AS [Username]
      ,NULL AS [Password]
      ,'School Tech Lead' AS [Role]