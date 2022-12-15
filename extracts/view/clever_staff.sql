USE gabby;

GO
CREATE OR ALTER VIEW
  extracts.clever_staff AS
  /*
  School staff assigned to primary school only
  Campus staff assigned to all schools at campus
   */
SELECT
  CAST(
    COALESCE(ccw.ps_school_id, df.primary_site_schoolid) AS VARCHAR(25)
  ) AS [School_id],
  df.ps_teachernumber AS [Staff_id],
  df.userprincipalname AS [Staff_email],
  df.preferred_first_name AS [First_name],
  df.preferred_last_name AS [Last_name],
  df.primary_on_site_department AS [Department],
  'School Admin' AS [Title],
  df.samaccountname AS [Username],
  NULL AS [Password],
  CASE
    WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead'
  END AS [Role]
FROM
  gabby.people.staff_crosswalk_static df
  LEFT JOIN gabby.people.campus_crosswalk ccw ON df.primary_site = ccw.campus_name
  AND ccw._fivetran_deleted = 0
  AND ccw.is_pathways = 0
WHERE
  df.[status] NOT IN ('TERMINATED', 'PRESTART')
  AND df.primary_on_site_department NOT IN ('Data', 'Teaching and Learning')
  AND COALESCE(ccw.ps_school_id, df.primary_site_schoolid) <> 0
UNION ALL
/* T&L/EDs/Data to all schools under CMO */
SELECT
  CAST(sch.school_number AS VARCHAR(25)) AS [School_id],
  df.ps_teachernumber AS [Staff_id],
  df.userprincipalname AS [Staff_email],
  df.preferred_first_name AS [First_name],
  df.preferred_last_name AS [Last_name],
  df.primary_on_site_department AS [Department],
  'School Admin' AS [Title],
  df.samaccountname AS [Username],
  NULL AS [Password],
  CASE
    WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead'
  END AS [Role]
FROM
  gabby.people.staff_crosswalk_static df
  INNER JOIN gabby.powerschool.schools sch ON sch.state_excludefromreporting = 0
WHERE
  df.[status] NOT IN ('TERMINATED', 'PRESTART')
  AND df.legal_entity_name = 'KIPP TEAM and Family Schools Inc.'
  AND (
    df.primary_on_site_department IN ('Data', 'Teaching and Learning')
    OR df.primary_job IN ('Executive Director', 'Managing Director')
  )
UNION ALL
/* All region */
SELECT
  CAST(sch.school_number AS VARCHAR(25)) AS [School_id],
  df.ps_teachernumber AS [Staff_id],
  df.userprincipalname AS [Staff_email],
  df.preferred_first_name AS [First_name],
  df.preferred_last_name AS [Last_name],
  df.primary_on_site_department AS [Department],
  'School Admin' AS [Title],
  df.samaccountname AS [Username],
  NULL AS [Password],
  CASE
    WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead'
  END AS [Role]
FROM
  gabby.people.staff_crosswalk_static df
  INNER JOIN gabby.powerschool.schools sch ON df.[db_name] = sch.[db_name]
  AND sch.state_excludefromreporting = 0
WHERE
  df.[status] NOT IN ('TERMINATED', 'PRESTART')
  AND (
    df.primary_job IN ('Assistant Superintendent', 'Head of Schools')
    OR (
      df.primary_on_site_department = 'Special Education'
      AND df.primary_job LIKE '%Director%'
    )
  )
UNION ALL
/* All NJ */
SELECT
  CAST(sch.school_number AS VARCHAR(25)) AS [School_id],
  df.ps_teachernumber AS [Staff_id],
  df.userprincipalname AS [Staff_email],
  df.preferred_first_name AS [First_name],
  df.preferred_last_name AS [Last_name],
  df.primary_on_site_department AS [Department],
  'School Admin' AS [Title],
  df.samaccountname AS [Username],
  NULL AS [Password],
  CASE
    WHEN df.primary_on_site_department = 'Operations' THEN 'School Tech Lead'
  END AS [Role]
FROM
  gabby.adsi.group_membership adg
  INNER JOIN gabby.people.staff_crosswalk_static df ON adg.employee_number = df.df_employee_number
  AND df.[status] NOT IN ('TERMINATED', 'PRESTART')
  INNER JOIN gabby.powerschool.schools sch ON sch.schoolstate = 'NJ'
  AND sch.state_excludefromreporting = 0
WHERE
  adg.group_cn = 'Group Staff NJ Regional'
