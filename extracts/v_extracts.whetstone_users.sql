USE gabby
GO

CREATE OR ALTER VIEW extracts.whetstone_users AS

WITH managers AS (
  SELECT DISTINCT
         manager_df_employee_number
  FROM gabby.people.staff_crosswalk_static
 )

SELECT CONVERT(VARCHAR(25), scw.df_employee_number) AS user_internal_id
      ,CASE WHEN scw.primary_site_schoolid = 0 THEN NULL ELSE scw.primary_site END AS school_name
      ,scw.primary_on_site_department AS course_name
      ,CONVERT(VARCHAR(25), scw.manager_df_employee_number) AS coach_internal_id
      ,scw.preferred_first_name + ' ' + scw.preferred_last_name AS [user_name]
      ,CASE WHEN scw.[status] = 'TERMINATED' THEN 1 ELSE 0 END AS inactive
      ,scw.google_email AS user_email
      ,CASE
        WHEN scw.grades_taught = 10 THEN '10th grade'
        WHEN scw.grades_taught = 11 THEN '11th grade'
        WHEN scw.grades_taught = 12 THEN '12th grade'
        WHEN scw.grades_taught = 1 THEN '1st grade'
        WHEN scw.grades_taught = 2 THEN '2nd grade'
        WHEN scw.grades_taught = 3 THEN '3rd grade'
        WHEN scw.grades_taught = 4 THEN '4th grade'
        WHEN scw.grades_taught = 5 THEN '5th grade'
        WHEN scw.grades_taught = 6 THEN '6th grade'
        WHEN scw.grades_taught = 7 THEN '7th grade'
        WHEN scw.grades_taught = 8 THEN '8th grade'
        WHEN scw.grades_taught = 9 THEN '9th grade'
        WHEN scw.grades_taught = 0 THEN 'Kindergarten'
       END AS grade_name
      ,CASE
        WHEN m.manager_df_employee_number IS NOT NULL THEN 'observers'
        ELSE 'observees'
       END AS group_type
      ,CASE
        WHEN m.manager_df_employee_number IS NOT NULL THEN 'Coach'
        ELSE 'Teacher'
       END AS role_name
      ,'Teachers' AS group_name
FROM gabby.people.staff_crosswalk_static scw
LEFT JOIN managers m
  ON scw.df_employee_number = m.manager_df_employee_number
WHERE scw.userprincipalname IS NOT NULL
  AND COALESCE(scw.termination_date, CURRENT_TIMESTAMP) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)
  AND ((scw.primary_on_site_department = 'School Leadership')
         OR (scw.primary_job IN ('Teacher', 'Co-Teacher', 'Learning Specialist', 'Learning Specialist Coordinator','Teacher in Residence', 'Teaching Fellow'))
         OR (primary_on_site_department = 'Special Education' AND primary_job = 'Director'))
