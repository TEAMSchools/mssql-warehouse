USE gabby;
GO

CREATE OR ALTER VIEW extracts.renlearn_teachers AS

SELECT scw.ps_teachernumber AS id
      ,scw.ps_teachernumber AS teachernumber
      ,COALESCE(ccw.ps_school_id, scw.primary_site_schoolid) AS schoolid
      ,scw.preferred_last_name AS last_name
      ,scw.preferred_first_name AS first_name
      ,NULL AS middle_name
      ,scw.samaccountname AS teacherloginid
      ,scw.userprincipalname AS staff_email
FROM gabby.people.staff_crosswalk_static scw
LEFT JOIN gabby.people.campus_crosswalk ccw
  ON scw.primary_site = ccw.campus_name
 AND ccw.is_pathways = 0
 AND ccw._fivetran_deleted = 0
WHERE scw.[status] != 'TERMINATED'
  AND COALESCE(ccw.ps_school_id, scw.primary_site_schoolid) != 0