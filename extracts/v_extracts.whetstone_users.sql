USE gabby
GO

CREATE OR ALTER VIEW extracts.whetstone_users AS

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
        ,gabby.dbo.GROUP_CONCAT_S(DISTINCT '"' + sub.role_name + '"', 1) AS role_names
  FROM
      (
       SELECT sogm.[user_id]
             ,r._id AS role_id
             ,r.[name] AS role_name
       FROM gabby.whetstone.schools_observation_groups_membership sogm
       JOIN gabby.whetstone.roles r
         ON sogm.role_category = r.category
        AND r.[name] IN ('Teacher', 'Coach')

       UNION ALL

       SELECT ur.[user_id]
             ,ur.role_id
             ,ur.role_name
       FROM gabby.whetstone.users_roles ur
       WHERE role_name <> 'No Role'

       UNION

       SELECT u.[user_id]
             ,r._id AS role_id
             ,r.[name] AS role_name
       FROM gabby.people.staff_crosswalk_static s
       INNER JOIN gabby.whetstone.users_clean u
         ON s.df_employee_number = u.internal_id
       INNER JOIN gabby.whetstone.roles r
         ON r.[name] = 'School Admin'
       WHERE s.primary_job = 'School Leader'

      ) sub
  GROUP BY sub.[user_id]
 )

,obsv_grp AS (
  SELECT [user_id]
        ,school_id
        ,observation_group_name
        ,gabby.dbo.GROUP_CONCAT_DS(role_name, ';', 1) AS role_names
  FROM gabby.whetstone.schools_observation_groups_membership
  WHERE observation_group_name = 'Teachers'
  GROUP BY [user_id], school_id, observation_group_name
 )

SELECT sub.user_internal_id
      ,sub.[user_name]
      ,sub.user_email
      ,sub.inactive

      ,u.[user_id]
      ,u.[user_email] AS user_email_ws
      ,u.[user_name] AS user_name_ws
      ,u.inactive AS inactive_ws
      ,u.default_school_id AS school_id_ws
      ,u.default_grade_level_id AS grade_id_ws
      ,u.default_course_id AS course_id_ws
      ,u.coach_id AS coach_id_ws
      ,CONVERT(DATE, u.archived_at) AS archived_at

      ,um.[user_id] AS coach_id

      ,sch._id AS school_id

      ,gr._id AS grade_id

      ,cou._id AS course_id

      ,'[' + er.role_ids + ']' AS role_id_ws

      ,og.role_names AS group_type_ws

      ,CASE
        WHEN er.role_names LIKE '%Admin%'
         AND CONVERT(DATE, GETDATE()) <> DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 8, 1)
             THEN NULL
        WHEN sub.role_name LIKE '%Admin%' THEN NULL
        WHEN sub.role_name = 'Coach' THEN 'observees;observers'
        ELSE 'observees'
       END AS group_type
      ,CASE
        WHEN er.role_names LIKE '%Admin%' 
         AND CONVERT(DATE, GETDATE()) <> DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 8, 1) 
             THEN NULL
        WHEN sub.role_name LIKE '%Admin%' THEN NULL
        ELSE 'Teachers'
       END AS group_name
      ,CASE 
        WHEN CONVERT(DATE, GETDATE()) = DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 8, 1) THEN '"' + sub.role_name + '"' /*removing last year roles every August*/
        WHEN er.role_names IS NULL THEN '"' + sub.role_name + '"' /* no roles = add assigned role */
        WHEN CHARINDEX(sub.role_name, er.role_names) > 0 THEN er.role_names /* assigned role already exists = use existing */
        ELSE '"' + sub.role_name + '",' + er.role_names /* add assigned role */
       END AS role_names
      ,'[' 
        + CASE 
           WHEN CONVERT(DATE, GETDATE()) = DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 8, 1) THEN '"' + r._id + '"' /*removing last year roles every August*/
           WHEN er.role_ids IS NULL THEN '"' + r._id + '"' /* no roles = add assigned role */
           WHEN CHARINDEX(r._id, er.role_ids) > 0 THEN er.role_ids /* assigned role already exists = use existing */
           ELSE '"' + r._id + '",' + er.role_ids /* add assigned role */
          END
        + ']' AS role_id
FROM
    (
     SELECT CONVERT(VARCHAR(25), scw.df_employee_number) AS user_internal_id
           ,CONVERT(VARCHAR(25), scw.manager_df_employee_number) AS manager_internal_id
           ,scw.google_email AS user_email
           ,scw.primary_on_site_department AS course_name
           ,scw.preferred_first_name + ' ' + scw.preferred_last_name AS [user_name]
           ,CASE WHEN scw.primary_site_schoolid <> 0 THEN scw.primary_site END AS school_name
           ,CONVERT(BIT, CASE WHEN scw.[status] = 'TERMINATED' THEN 1 ELSE 0 END) AS inactive
           ,CASE WHEN scw.grades_taught = 0 THEN 'K' ELSE CONVERT(VARCHAR, scw.grades_taught) END AS grade_abbreviation
           ,CASE
             /* network admins */
             WHEN scw.primary_on_site_department = 'Executive' THEN 'Regional Admin'
             WHEN scw.primary_on_site_department IN ('Teaching and Learning', 'School Support', 'New Teacher Development') 
              AND scw.primary_job IN ('Achievement Director', 'Chief Academic Officer', 'Chief Of Staff', 'Director', 'Head of Schools'
                                     ,'Director High School Literacy Curriculum', 'Director Literacy Achievement', 'Director Math Achievement'
                                     ,'Director Middle School Literacy Curriculum') 
                  THEN 'Sub Admin'
             WHEN scw.primary_on_site_department = 'Special Education' 
              AND scw.primary_job IN ('Managing Director', 'Director', 'Achievement Director') 
                  THEN 'Sub Admin'
             WHEN scw.primary_on_site_department = 'Human Resources'
                  THEN 'Sub Admin'
             /* school admins */
             WHEN scw.primary_job = 'School Leader' THEN 'School Admin'
             WHEN scw.primary_on_site_department = 'School Leadership' 
              AND scw.primary_job IN ('Assistant Dean', 'Assistant School Leader', 'Assistant School Leader, SPED', 'Dean'
                                     ,'Dean of Students', 'Director of New Teacher Development','School Leader in Residence') 
                  THEN 'School Assistant Admin' 
             /* basic roles */
             WHEN scw.is_manager = 1 THEN 'Coach'
             WHEN scw.primary_job IN ('Teacher', 'Teacher ESL', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator','Teacher in Residence', 'Teaching Fellow', 'Paraprofessional') THEN 'Teacher'
             ELSE 'No Role'
            END AS role_name
     FROM gabby.people.staff_crosswalk_static scw
     LEFT JOIN managers m
       ON scw.df_employee_number = m.manager_df_employee_number
     WHERE scw.userprincipalname IS NOT NULL
       AND COALESCE(scw.termination_date, CURRENT_TIMESTAMP) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)
       AND scw.primary_on_site_department <> 'Data'
    ) sub
LEFT JOIN gabby.whetstone.users_clean u
  ON sub.user_internal_id = u.internal_id
LEFT JOIN gabby.whetstone.users_clean um
  ON sub.manager_internal_id = um.internal_id
LEFT JOIN gabby.whetstone.schools sch
  ON sub.school_name = sch.[name]
LEFT JOIN gabby.whetstone.grades gr
  ON sub.grade_abbreviation = gr.abbreviation
LEFT JOIN gabby.whetstone.courses cou
  ON sub.course_name = cou.[name]
 AND cou.archived_at IS NULL
LEFT JOIN gabby.whetstone.roles r
  ON sub.role_name = r.[name]
LEFT JOIN existing_roles er
  ON u.[user_id] = er.[user_id]
LEFT JOIN obsv_grp og
  ON u.[user_id] = og.[user_id]
 AND sch._id = og.school_id
WHERE sub.role_name <> 'No Role'
