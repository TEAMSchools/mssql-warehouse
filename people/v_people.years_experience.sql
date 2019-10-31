USE gabby
GO

CREATE OR ALTER VIEW people.years_experience AS:

WITH months AS (

  SELECT df_employee_id
        ,active AS months_active
        ,inactive AS months_inactive
  FROM (SELECT df_employee_id
              ,CASE WHEN status = 'Active' THEN 'active' else 'inactive' END AS status_clean
              ,DATEDIFF(month,effective_start_date,effective_end_date) AS months 
        FROM gabby.dayforce.work_assignment_status 
        WHERE status != 'Terminated' 
          AND status != 'Pre-Start'
          AND job_name != 'intern'
          ) sub
        PIVOT(
              SUM(months) for status_clean IN (active, inactive)
             ) p
  )
 
 ,years_teaching_at_kipp AS (
   SELECT was.df_employee_id
         ,SUM(DATEDIFF(MONTH,was.effective_start_date,was.effective_end_date)) AS months_as_teacher
   FROM gabby.dayforce.work_assignment_status was
   WHERE job_name IN ('Teacher'
                     ,'Learning Specialist'
                     ,'Learning Specialist Coordinator'
                     ,'Teacher in Residence'
                     ,'Teacher, ESL'
                     ,'Co-Teachr')
     AND status NOT IN ('Terminated', 'Prestart')
     GROUP BY df_employee_id)

,df_sf_teaching AS (

  SELECT r.df_employee_number
        ,y.months_as_teacher/12 AS years_teaching_at_kipp
        ,a.years_of_full_time_teaching AS years_teaching_prior_to_kipp
        ,a.years_full_time_experience AS years_experience_prior_to_kipp
  FROM gabby.tableau.staff_roster r
  JOIN years_teaching_at_kipp y
    ON r.df_employee_number = y.df_employee_id
  LEFT JOIN gabby.recruiting.applicants a
    ON r.salesforce_job_position_name_custom = a.position_number

  WHERE r.job_title_custom IN ('Teacher'
                            ,'Learning Specialist'
                            ,'Learning Specialist Coordinator'
                            ,'Teacher in Residence'
                            ,'Teacher, ESL')
      AND r.position_status != 'Terminated'

      )


SELECT r.df_employee_number
      ,r.preferred_name
      ,r.userprincipalname
      ,r.legal_entity_name AS current_legal_entity
      ,r.location_description AS current_location
      ,r.job_title_description AS current_job
      ,r.position_status AS current_position_status
      ,r.original_hire_date
      ,r.rehire_date
      ,ROUND(m.months_active/12.0,2) AS years_active_at_kipp
      ,COALESCE(ROUND(m.months_inactive/12.0,2),0) AS years_inactive_at_kipp
      ,COALESCE(ROUND(m.months_active/12.0,2) + ROUND(m.months_inactive/12.0,2),ROUND(m.months_active/12.0,2)) AS years_at_kipp_total
      ,COALESCE(dst.years_teaching_at_kipp,0) AS years_teaching_at_kipp
      ,dst.years_experience_prior_to_kipp --null = no input from salesforce
      ,dst.years_teaching_prior_to_kipp --null = no input from salesforce
      ,COALESCE(dst.years_teaching_at_kipp,0) + COALESCE(dst.years_teaching_prior_to_kipp,0) AS years_teaching_total
      ,COALESCE(ROUND(m.months_active/12.0,2) + ROUND(m.months_inactive/12.0,2),ROUND(m.months_active/12.0,2)) + COALESCE(dst.years_experience_prior_to_kipp,0) AS years_experience_total
FROM tableau.staff_roster r
LEFT JOIN months m
  ON r.df_employee_number = m.df_employee_id
LEFT JOIN df_sf_teaching dst
  ON r.df_employee_number = dst.df_employee_number

