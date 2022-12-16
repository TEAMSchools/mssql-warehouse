CREATE OR ALTER VIEW
  extracts.illuminate_roles AS
  /* KNJ specific departments = all CMO schools */
SELECT
  df.ps_teachernumber AS [01 Local User ID],
  sch.school_number AS [02 Site ID],
  'School Leadership' AS [03 Role Name],
  CONCAT(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    '-',
    (gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1)
  ) AS [04 Academic Year],
  1 AS [05 Session Type ID]
FROM
  gabby.people.staff_crosswalk_static AS df
  INNER JOIN gabby.powerschool.schools AS sch ON sch.state_excludefromreporting = 0
WHERE
  df.[status] != 'TERMINATED'
  AND df.primary_on_site_department IN (
    'Teaching and Learning',
    'Data',
    'Executive'
  )
  AND df.legal_entity_name = 'KIPP TEAM and Family Schools Inc.'
UNION ALL
/* Campus-based staff = all schools at campus */
SELECT
  df.ps_teachernumber AS [01 Local User ID],
  cc.ps_school_id AS [02 Site ID],
  'School Leadership' AS [03 Role Name],
  CONCAT(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    '-',
    (gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1)
  ) AS [04 Academic Year],
  1 AS [05 Session Type ID]
FROM
  gabby.people.staff_crosswalk_static AS df
  INNER JOIN gabby.people.campus_crosswalk AS cc ON df.primary_site = cc.campus_name
  AND cc.is_pathways = 0
  AND cc._fivetran_deleted = 0
WHERE
  df.[status] != 'TERMINATED'
  AND df.primary_on_site_department NOT IN (
    'Teaching and Learning',
    'Data',
    'Executive'
  )
  AND df.is_campus_staff = 1
UNION ALL
/* School-based staff = only respective school */
SELECT
  df.ps_teachernumber AS [01 Local User ID],
  df.primary_site_schoolid AS [02 Site ID],
  'School Leadership' AS [03 Role Name],
  CONCAT(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    '-',
    (gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1)
  ) AS [04 Academic Year],
  1 AS [05 Session Type ID]
FROM
  gabby.people.staff_crosswalk_static AS df
WHERE
  df.[status] != 'TERMINATED'
  AND df.primary_on_site_department NOT IN (
    'Teaching and Learning',
    'Data',
    'Executive'
  )
  AND df.is_campus_staff = 0
