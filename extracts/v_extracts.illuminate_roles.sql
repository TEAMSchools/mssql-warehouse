USE gabby
GO

CREATE OR ALTER VIEW extracts.illuminate_roles AS

/* KNJ specific departments = all CMO schools */
SELECT COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [01 Local User ID]
      ,sch.school_number AS [02 Site ID]
      ,'School Leadership' AS [03 Role Name]
      ,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR() , '-', (gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1))  AS [04 Academic Year]
      ,1 AS [05 Session Type ID]
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
JOIN gabby.powerschool.schools sch
  ON sch.state_excludefromreporting = 0
WHERE df.is_active = 1
  AND df.primary_on_site_department IN ('Teaching and Learning', 'Data', 'Executive', 'School Support')
  AND df.legal_entity_name = 'KIPP New Jersey'

UNION ALL

/* R9/R10 regional = all schools in region */
SELECT COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [01 Local User ID]
      ,sch.school_number AS [02 Site ID]
      ,'School Leadership' AS [03 Role Name]
      ,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR() , '-', (gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1))  AS [04 Academic Year]
      ,1 AS [05 Session Type ID]
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
JOIN gabby.powerschool.schools sch
  ON CASE 
      WHEN df.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
      WHEN df.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
      WHEN df.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
      WHEN df.legal_entity_name = 'KIPP New Jersey' THEN sch.db_name
     END = sch.db_name
 AND sch.state_excludefromreporting = 0
WHERE df.is_active = 1
  AND primary_site IN ('Room 9 - 60 Park Pl','Room 10 - 740 Chestnut St')
  AND legal_entity_name != 'KIPP New Jersey'

UNION ALL

/* Campus-based staff = all schools at campus */
SELECT COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [01 Local User ID]
      ,sch.school_number AS [02 Site ID]
      ,'School Leadership' AS [03 Role Name]
      ,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR() , '-', (gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1))  AS [04 Academic Year]
      ,1 AS [05 Session Type ID]
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
CROSS APPLY STRING_SPLIT(CASE 
                          WHEN df.primary_site = 'KIPP Lanning Sq Campus' THEN '179901,179902'
                          WHEN df.primary_site = '18th Ave Campus' THEN '73255,73258'
                         END, ',') ss
JOIN gabby.powerschool.schools sch
  ON ss.value = sch.school_number
WHERE df.is_active = 1
  AND df.primary_site IN ('18th Ave Campus', 'KIPP Lanning Sq Campus')

UNION ALL

/* School-based staff = only respective school */
SELECT COALESCE(id.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) AS [01 Local User ID]
      ,sch.school_number AS [02 Site ID]
      ,'School Leadership' AS [03 Role Name]
      ,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR() , '-', (gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1))  AS [04 Academic Year]
      ,1 AS [05 Session Type ID]
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.people.id_crosswalk_powerschool id
  ON df.df_employee_number = id.df_employee_number
 AND id.is_master = 1
JOIN gabby.powerschool.schools sch
  ON df.primary_site_schoolid = sch.school_number
WHERE df.is_active = 1
  AND primary_site NOT IN ('Room 9 - 60 Park Pl','Room 10 - 740 Chestnut St','18th Ave Campus','KIPP Lanning Sq Campus')
  AND legal_entity_name != 'KIPP New Jersey'