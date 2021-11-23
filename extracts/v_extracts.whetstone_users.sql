USE gabby
GO

CREATE OR ALTER VIEW extracts.whetstone_users AS

--staff_info CTE gets info from staff roster: employee id (ADP), name (ADP), status (ADP), campus (ADP), whether a manager (ADP),
--assigns Whetstone role category by job title or central department, assigns coach id based on ADP manager,
--whether active in Whetstone, when inactivated in Whetstone, courses taught (ADP) and grades taught (ADP).
WITH staff_info AS (
     SELECT CONVERT(VARCHAR(25), scw.df_employee_number) AS user_internal_id
           ,scw.preferred_first_name + ' ' + scw.preferred_last_name AS [user_name]
           ,scw.google_email AS user_email
           ,CONVERT(BIT, CASE WHEN scw.[status] = 'TERMINATED' THEN 1 ELSE 0 END) AS inactive
           ,scw.primary_job as primary_job
           ,scw.primary_on_site_department AS department
           ,CASE
              WHEN scw.primary_on_site_department IN (
               'Executive'
              ) THEN 'Regional Admin'
              WHEN scw.primary_on_site_department IN (
                'Teaching and Learning'
               ,'School Support'
               ,'New Teacher Development'
               ) THEN 'Sub Admin'
              WHEN scw.primary_on_site_department = 'Special Education' AND SCW.primary_job NOT IN ( 
                'Teacher'
               ,'Teacher ESL'
               ,'Co-Teacher'
               ,'Learning Specialist'
               ,'Learning Specialist Coordinator'
               ,'Teacher in Residence'
               ,'Teaching Fellow'
               ,'Paraprofessional'
               ,'Learning Disabilities Teacher Consultant'
               ,'Occupational Therapist'
               ,'School Psychologist'
               ,'Specialist'
               ,'Speech Language Pathologist')
               THEN 'Sub Admin'
              WHEN scw.primary_job IN (
                'School Leader'
               ) THEN 'School Admin'
              WHEN scw.primary_on_site_department IN (
                'School Leadership'
               ) THEN 'School Assistant Admin'
              WHEN scw.primary_on_site_department IN (
                'Data'
               ) THEN 'System Admin'
              WHEN scw.is_manager = 1 THEN 'Coach'-- ?
              WHEN scw.primary_job IN (
                'Teacher'
               ,'Teacher ESL'
               ,'Co-Teacher'
               ,'Learning Specialist'
               ,'Learning Specialist Coordinator'
               ,'Teacher in Residence'
               ,'Teaching Fellow'
               ,'Paraprofessional' 
               ) THEN 'Teacher'
              ELSE 'No Role' END AS group_name
            ,um.[user_id] AS [user_id]
            ,scw.manager_name
            ,scw.manager_df_employee_number AS manager_id
            ,um.coach_id AS coach_id
            ,um.inactive AS inactive_ws
            ,CONVERT(DATE, um.archived_at) AS archived_at
            ,sch._id AS school_id
            ,scw.primary_on_site_department AS course_name
            ,CASE WHEN scw.grades_taught = 0 THEN 'K' ELSE CONVERT(VARCHAR, scw.grades_taught) END AS grade_abbreviation
     FROM gabby.people.staff_crosswalk_static scw
     LEFT JOIN gabby.whetstone.users_clean um
       ON scw.df_employee_number = um.internal_id
     LEFT JOIN gabby.whetstone.schools sch
       ON scw.primary_site = sch.[name]
     LEFT JOIN gabby.whetstone.users_clean uc
       ON scw.df_employee_number = uc.internal_id
       )

--existing_roles CTE concatenates all roles present for user in Whetstone now, adds new role if not present.
,
existing_roles AS (
  SELECT sogm.[user_id]
        ,gabby.dbo.GROUP_CONCAT(DISTINCT '"' + r._id + '"') AS role_ids_old 
  FROM gabby.whetstone.schools_observation_groups_membership sogm
  JOIN gabby.whetstone.roles r
    ON sogm.role_category = r.category
  GROUP BY sogm.[user_id]
  )

SELECT si.user_internal_id
      ,si.[user_name]
      ,si.primary_job
      ,si.department
      ,si.user_email
      ,si.inactive
      ,CASE
       WHEN si.group_name = 'Teacher'
           THEN 'observee'
       WHEN si.group_name IN ('Coach','School Assistant Admin', 'School Admin','Regional Admin','Sub Admin','System Admin')
           THEN 'observer'
           ELSE NULL END AS group_type
      ,si.group_name
      ,si.[user_id]
      ,si.inactive_ws
      ,si.archived_at
      ,si.coach_id
      ,si.school_id
      ,gr._id AS grade_id
      ,cou._id AS course_id
      ,CASE 
        WHEN si.group_name = 'No Role' THEN er.role_ids_old
        WHEN er.role_ids_old IS NULL THEN '"' + r._id + '"'
        WHEN CHARINDEX(r._id,er.role_ids_old)>0 THEN er.role_ids_old
        ELSE '"' + r._id + '", ' + er.role_ids_old
       END AS role_id

FROM staff_info si
LEFT JOIN gabby.whetstone.grades gr
      ON si.grade_abbreviation = gr.abbreviation
LEFT JOIN gabby.whetstone.courses cou
      ON si.course_name = cou.[name]
LEFT JOIN gabby.whetstone.roles r
      ON si.group_name = r.[name]
LEFT JOIN existing_roles er
  ON si.[user_id] = er.[user_id]
