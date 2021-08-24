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
  WHERE s.primary_job IN ('School Leader', 'Assistant School Leader', 'Assistant School Leader, SPED')
 )

SELECT sub.user_internal_id
      ,sub.[user_name]
      ,sub.user_email
      ,sub.inactive
      ,sub.group_type
      ,'Teachers' AS group_name

      ,u.[user_id]
      ,u.inactive AS inactive_ws
      ,CONVERT(DATE, u.archived_at) AS archived_at

      ,um.[user_id] AS coach_id
      ,sch._id AS school_id
      ,gr._id AS grade_id
      ,cou._id AS course_id
      ,r._id AS role_id
FROM
    (
     SELECT CONVERT(VARCHAR(25), scw.df_employee_number) AS user_internal_id
           ,CONVERT(VARCHAR(25), scw.manager_df_employee_number) AS manager_internal_id
           ,scw.preferred_first_name + ' ' + scw.preferred_last_name AS [user_name]
           ,CONVERT(BIT, CASE WHEN scw.[status] = 'TERMINATED' THEN 1 ELSE 0 END) AS inactive
           ,scw.google_email AS user_email
           ,CASE WHEN scw.primary_site_schoolid = 0 THEN NULL ELSE scw.primary_site END AS school_name
           ,scw.primary_on_site_department AS course_name
           ,CASE WHEN scw.grades_taught = 0 THEN 'K' ELSE CONVERT(VARCHAR, scw.grades_taught) END AS grade_abbreviation
           ,CASE
             WHEN m.manager_df_employee_number IS NOT NULL THEN 'Coach'
             ELSE 'Teacher'
            END AS role_name
           ,CASE
             WHEN m.manager_df_employee_number IS NOT NULL THEN 'observers'
             ELSE 'observees'
            END AS group_type
     FROM gabby.people.staff_crosswalk_static scw
     LEFT JOIN managers m
       ON scw.df_employee_number = m.manager_df_employee_number
     WHERE scw.userprincipalname IS NOT NULL
       AND COALESCE(scw.termination_date, CURRENT_TIMESTAMP) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)
       AND ((scw.primary_on_site_department = 'School Leadership')
              OR (scw.primary_job IN ('Teacher', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator','Teacher in Residence', 'Teaching Fellow'))
              OR (primary_on_site_department = 'Special Education' AND primary_job = 'Director'))
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
