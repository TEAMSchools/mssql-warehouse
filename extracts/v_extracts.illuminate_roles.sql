USE gabby
GO

CREATE OR ALTER VIEW extracts.illuminate_roles AS

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