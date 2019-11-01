USE gabby;
GO

CREATE OR ALTER VIEW people.years_experience AS

WITH months AS (
 SELECT df_employee_id
       ,ISNULL(active, 0) AS months_active
       ,ISNULL(inactive, 0) AS months_inactive
 FROM 
     (
      SELECT df_employee_id
            ,CASE
              WHEN [status] = 'Active' THEN 'active'
              ELSE 'inactive'
             END AS status_clean
            ,DATEDIFF(MONTH, effective_start_date, effective_end_date) AS months
      FROM gabby.dayforce.work_assignment_status
      WHERE [status] NOT IN ('Terminated', 'Pre-Start')
        AND job_name != 'Intern'
     ) sub
 PIVOT (
   SUM(months)
   FOR status_clean IN (active, inactive)
  ) p
 )

,years_teaching_at_kipp AS (
  SELECT was.df_employee_id
        ,SUM(DATEDIFF(MONTH, was.effective_start_date, was.effective_end_date)) AS months_as_teacher
  FROM gabby.dayforce.work_assignment_status was
  WHERE was.[status] NOT IN ('Terminated', 'Pre-Start')
    AND was.job_name IN ('Teacher'
                        ,'Learning Specialist'
                        ,'Learning Specialist Coordinator'
                        ,'Teacher in Residence'
                        ,'Teacher, ESL'
                        ,'Co-Teacher')
  GROUP BY was.df_employee_id
 )

SELECT r.df_employee_number
      ,r.preferred_name
      ,r.userprincipalname
      ,r.legal_entity_name AS current_legal_entity
      ,r.primary_site AS current_location
      ,r.primary_job AS current_job
      ,r.[status] AS current_position_status
      ,r.original_hire_date
      ,r.rehire_date

      ,ROUND(m.months_active / 12.0, 2) AS years_active_at_kipp
      ,ROUND(m.months_inactive / 12.0, 2) AS years_inactive_at_kipp
      ,ROUND(m.months_active / 12.0, 2) 
         + ROUND(m.months_inactive / 12.0, 2) AS years_at_kipp_total

      ,ISNULL((y.months_as_teacher / 12), 0) AS years_teaching_at_kipp

      ,ISNULL(dst.years_of_full_time_teaching, 0) AS years_teaching_prior_to_kipp
      ,ISNULL(dst.years_full_time_experience, 0) AS years_experience_prior_to_kipp
      
      ,ISNULL((y.months_as_teacher / 12), 0) 
         + ISNULL(dst.years_of_full_time_teaching, 0) AS years_teaching_total
      ,ROUND(m.months_active / 12.0, 2)
         + ROUND(m.months_inactive / 12.0, 2)
         + ISNULL(dst.years_full_time_experience, 0) AS years_experience_total
FROM gabby.people.staff_crosswalk_static r
LEFT JOIN months m
  ON r.df_employee_number = m.df_employee_id
LEFT JOIN gabby.recruiting.applicants dst
  ON r.salesforce_id = dst.position_number
LEFT JOIN years_teaching_at_kipp y
  ON r.df_employee_number = y.df_employee_id