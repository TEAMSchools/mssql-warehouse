USE gabby
GO

--CREATE OR ALTER VIEW extracts.whetstone_users AS

WITH managers AS (
  SELECT DISTINCT
         manager_df_employee_number
  FROM gabby.people.staff_crosswalk_static

  UNION

  SELECT s.df_employee_number
  FROM gabby.people.staff_crosswalk_static s
  WHERE s.primary_job IN ('School Leader', 'Assistant School Leader', 'Assistant School Leader, SPED', 'School Leader in Residence')
 )

,existing_roles AS (
  SELECT sub.[user_id]
        ,gabby.dbo.GROUP_CONCAT_S(DISTINCT '"' + sub.role_id + '"', 1) AS role_ids
  FROM
      (
       SELECT sogm.[user_id]
             ,r._id AS role_id
       FROM gabby.whetstone.schools_observation_groups_membership sogm
       JOIN gabby.whetstone.roles r
         ON sogm.role_category = r.category
        AND r.[name] IN ('Teacher', 'Coach')

       UNION ALL

       SELECT ur.[user_id]
             ,ur.role_id
       FROM gabby.whetstone.users_roles ur
      ) sub
  GROUP BY sub.[user_id]
 )

SELECT si.user_internal_id
      ,si.[user_name]
      ,si.primary_job
      ,si.department
      ,si.user_email
      ,si.inactive
      ,si.group_name
      ,si.[user_id]
      ,si.inactive_ws
      ,si.archived_at
      ,si.coach_id
      ,si.school_id
      ,CASE
        WHEN si.group_name = 'Teacher' THEN 'observee'
        WHEN si.group_name IN ('Coach', 'School Assistant Admin', 'School Admin', 'Regional Admin', 'Sub Admin', 'System Admin') THEN 'observer'
        ELSE NULL
       END AS group_type

      ,gr._id AS grade_id

      ,cou._id AS course_id

      ,CASE 
        WHEN si.group_name = 'No Role' THEN er.role_ids_old
        WHEN er.role_ids_old IS NULL THEN '"' + r._id + '"'
        WHEN CHARINDEX(r._id, er.role_ids_old) > 0 THEN er.role_ids_old
        ELSE '"' + r._id + '", ' + er.role_ids_old
       END AS role_id
FROM
    (
     SELECT CONVERT(VARCHAR(25), scw.df_employee_number) AS user_internal_id
           ,scw.google_email AS user_email
           ,scw.primary_job as primary_job
           ,scw.primary_on_site_department AS department
           ,scw.primary_on_site_department AS course_name
           ,scw.manager_name
           ,scw.manager_df_employee_number AS manager_id
           ,scw.preferred_first_name + ' ' + scw.preferred_last_name AS [user_name]
           ,CONVERT(BIT, CASE WHEN scw.[status] = 'TERMINATED' THEN 1 ELSE 0 END) AS inactive
           ,CASE WHEN scw.grades_taught = 0 THEN 'K' ELSE CONVERT(VARCHAR, scw.grades_taught) END AS grade_abbreviation
           ,CASE
              WHEN scw.primary_on_site_department IN ('Executive') THEN 'Regional Admin' -- network admin
              WHEN scw.primary_on_site_department IN ('Teaching and Learning', 'School Support', 'New Teacher Development') THEN 'Sub Admin' -- network admin
              WHEN scw.primary_on_site_department = 'Special Education'
               AND scw.primary_job NOT IN ('Teacher', 'Teacher ESL', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator'
                                          ,'Teacher in Residence', 'Teaching Fellow', 'Paraprofessional', 'Learning Disabilities Teacher Consultant'
                                          ,'Occupational Therapist', 'School Psychologist', 'Specialist', 'Speech Language Pathologist')
                   THEN 'Sub Admin' -- network admin
              WHEN scw.primary_job IN ('School Leader') THEN 'School Admin'
              WHEN scw.primary_on_site_department IN ('School Leadership') THEN 'School Assistant Admin'
              WHEN scw.primary_on_site_department IN ('Data') THEN 'System Admin' -- network admin
              WHEN scw.is_manager = 1 THEN 'Coach'-- ?
              WHEN scw.primary_job IN ('Teacher', 'Teacher ESL', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator'
                                      ,'Teacher in Residence', 'Teaching Fellow', 'Paraprofessional') 
                   THEN 'Teacher'
              ELSE 'No Role'
             END AS group_name

            ,um.[user_id] AS [user_id]
            ,um.coach_id AS coach_id
            ,um.inactive AS inactive_ws
            ,CONVERT(DATE, um.archived_at) AS archived_at

            ,sch._id AS school_id
     FROM gabby.people.staff_crosswalk_static scw
     LEFT JOIN gabby.whetstone.users_clean um
       ON scw.df_employee_number = um.internal_id
     LEFT JOIN gabby.whetstone.schools sch
       ON scw.primary_site = sch.[name]
    ) si
LEFT JOIN gabby.whetstone.grades gr
  ON si.grade_abbreviation = gr.abbreviation
LEFT JOIN gabby.whetstone.courses cou
  ON si.course_name = cou.[name]
LEFT JOIN gabby.whetstone.roles r
  ON si.group_name = r.[name]
LEFT JOIN existing_roles er
  ON si.[user_id] = er.[user_id]
