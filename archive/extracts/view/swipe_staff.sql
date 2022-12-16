CREATE OR ALTER VIEW
  extracts.swipe_staff AS
SELECT
  COALESCE(ccw.ps_school_id, scw.primary_site_schoolid) AS [PS Building ID],
  scw.df_employee_number AS [Staff ID],
  scw.preferred_last_name AS [Staff Last Name],
  scw.preferred_first_name AS [Staff First Name],
  scw.primary_job AS [Title],
  scw.legal_entity_name AS [Legal Entity Name]
FROM
  gabby.people.staff_crosswalk_static AS scw
  LEFT JOIN gabby.people.campus_crosswalk AS ccw ON scw.primary_site = ccw.campus_name
  AND ccw._fivetran_deleted = 0
  AND ccw.is_pathways = 0
WHERE
  scw.[status] != 'TERMINATED'
  AND COALESCE(ccw.ps_school_id, scw.primary_site_schoolid) != 0
