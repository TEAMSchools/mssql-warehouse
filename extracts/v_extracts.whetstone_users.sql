USE gabby
GO

CREATE OR ALTER VIEW extracts.whetstone_users AS

WITH managers AS (
  SELECT DISTINCT
         manager_df_employee_number
  FROM gabby.people.staff_crosswalk_static
  WHERE [status] != 'TERMINATED'
 )

SELECT scw.df_employee_number AS accounting_id
      ,scw.primary_site AS school_name
      ,scw.primary_on_site_department AS course_name
      ,scw.manager_df_employee_number AS coach_accounting_id
      ,scw.preferred_first_name + ' ' + scw.preferred_last_name AS name
      ,CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org' 
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS email
      ,CASE
        WHEN scw.grades_taught = 'Grade 10' THEN '10th grade'
        WHEN scw.grades_taught = 'Grade 11' THEN '11th grade'
        WHEN scw.grades_taught = 'Grade 12' THEN '12th grade'
        WHEN scw.grades_taught = 'Grade 1' THEN '1st grade'
        WHEN scw.grades_taught = 'Grade 2' THEN '2nd grade'
        WHEN scw.grades_taught = 'Grade 3' THEN '3rd grade'
        WHEN scw.grades_taught = 'Grade 4' THEN '4th grade'
        WHEN scw.grades_taught = 'Grade 5' THEN '5th grade'
        WHEN scw.grades_taught = 'Grade 6' THEN '6th grade'
        WHEN scw.grades_taught = 'Grade 7' THEN '7th grade'
        WHEN scw.grades_taught = 'Grade 8' THEN '8th grade'
        WHEN scw.grades_taught = 'Grade 9' THEN '9th grade'
        WHEN scw.grades_taught = 'Kindergarten' THEN 'Kindergarten'
       END AS grade_name

      ,CASE
        WHEN m.manager_df_employee_number IS NOT NULL THEN 'observer'
        ELSE 'observee'
       END AS user_level
FROM gabby.people.staff_crosswalk_static scw
LEFT JOIN managers m
  ON scw.df_employee_number = m.manager_df_employee_number
WHERE scw.[status] != 'TERMINATED'
  AND scw.userprincipalname IS NOT NULL
  AND (scw.primary_on_site_department = 'School Leadership'
       OR scw.primary_job IN ('Teacher', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator','Teacher in Residence', 'Teaching Fellow'))