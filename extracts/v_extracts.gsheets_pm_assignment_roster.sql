USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_pm_assignment_roster AS

WITH elementary_grade AS (
  SELECT employee_number
        ,MAX(student_grade_level) AS student_grade_level
  FROM gabby.pm.teacher_grade_levels
  GROUP BY employee_number
 )

/*active staff info*/
SELECT 
       s.df_employee_number
      ,s.preferred_name
      ,s.primary_job
      ,s.google_email
      ,s.userprincipalname AS user_email
      ,s.primary_site
      ,s.legal_entity_name
      ,s.manager_df_employee_number
      /*default assignments based on title/location*/
      ,CASE 
        WHEN s.primary_site IN ('Room 9 - 60 Park Pl', 'Room 10 - 121 Market St', 'Room 11 - 1951 NW 7th Ave') THEN 'Regional Staff'
        WHEN s.primary_job IN ('Teacher', 'Teacher in Residence', 'Learning Specialist', 'Learning Specialist Coordinator', 'Teacher, ESL', 'Teacher ESL') THEN 'Teacher'
        WHEN s.primary_on_site_department = 'School Leadership' THEN 'School Leadership Team'
        ELSE 'Non-teaching school based staff'
       END AS tntp_assignment
      ,CASE 
        WHEN s.primary_job = 'Head of Schools' THEN 'Head of Schools'
        WHEN s.primary_job = 'Assistant Superintendent' THEN 'Head of Schools'
        WHEN s.primary_job IN ('Teacher', 'Teacher in Residence', 'Learning Specialist', 'Learning Specialist Coordinator', 'Teacher, ESL', 'Teacher ESL') THEN 'Teacher'
        WHEN s.primary_job = 'Executive Director' THEN 'Executive Director'
        WHEN s.primary_job IN ('Associate Director of School Operations') THEN 'ADSO'
        WHEN s.primary_job IN ('Director Campus Operations', 'Director School Operations', 'Director of Campus Operations', 'Fellow School Operations Director') THEN 'DSO'
        WHEN s.primary_job = 'Managing Director of Operations' THEN 'MDO'
        WHEN s.primary_job = 'Managing Director of School Operations' THEN 'MDSO'
        WHEN s.primary_job = 'School Leader' THEN 'School Leader'
        WHEN s.primary_job IN ('Assistant School Leader', 'Assistant School Leader, SPED', 'School Leader in Residence') THEN 'AP'
        ELSE 'Other'
       END AS engagement_survey_assignment
      ,CASE
        WHEN s.primary_on_site_department = 'Elementary' AND e.student_grade_level IS NOT NULL
             THEN CONCAT(s.primary_on_site_department, ', Grade ', e.student_grade_level)
        ELSE s.primary_on_site_department
       END AS department_grade
FROM gabby.people.staff_crosswalk_static s
LEFT JOIN elementary_grade e
  ON s.df_employee_number = e.employee_number
WHERE s.[status] = 'ACTIVE'
  AND s.primary_job <> 'Intern'
  AND s.primary_job NOT LIKE '%Temp%'