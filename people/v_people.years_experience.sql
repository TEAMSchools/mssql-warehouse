USE gabby;
GO

CREATE OR ALTER VIEW people.years_experience AS

WITH months AS (
  SELECT employee_number
        ,ISNULL(active, 0) AS months_active
        ,ISNULL(inactive, 0) AS months_inactive
  FROM 
      (
       SELECT employee_number
             ,CASE
               WHEN position_status = 'Active' THEN 'active'
               ELSE 'inactive'
              END AS status_clean
             ,DATEDIFF(MONTH, effective_start_date, effective_end_date) AS months
       FROM gabby.people.employment_history
       WHERE position_status NOT IN ('Terminated', 'Pre-Start')
         AND job_title <> 'Intern'
      ) sub
  PIVOT (
    SUM(months)
    FOR status_clean IN (active, inactive)
   ) p
 )

,years_teaching_at_kipp AS (
  SELECT was.employee_number
        ,SUM(DATEDIFF(MONTH, was.effective_start_date, was.effective_end_date)) AS months_as_teacher
  FROM gabby.people.employment_history was
  WHERE was.position_status NOT IN ('Terminated', 'Pre-Start')
    AND was.job_title IN ('Teacher', 'Learning Specialist', 'Learning Specialist Coordinator', 'Teacher in Residence', 'Teacher, ESL', 'Teacher ESL', 'Co-Teacher')
  GROUP BY was.employee_number
 )

SELECT m.employee_number
      ,ROUND(m.months_active / 12.0, 2) AS years_active_at_kipp
      ,ROUND(m.months_inactive / 12.0, 2) AS years_inactive_at_kipp
      ,ROUND(m.months_active / 12.0, 2) 
         + ROUND(m.months_inactive / 12.0, 2) AS years_at_kipp_total

      ,ISNULL((y.months_as_teacher / 12), 0) AS years_teaching_at_kipp

      --,ISNULL(dst.years_of_full_time_teaching, 0) AS years_teaching_prior_to_kipp
      --,ISNULL(dst.years_full_time_experience, 0) AS years_experience_prior_to_kipp
      ,0 AS years_teaching_prior_to_kipp
      ,0 AS years_experience_prior_to_kipp

      ,ISNULL((y.months_as_teacher / 12), 0) 
         --+ ISNULL(dst.years_of_full_time_teaching, 0)
         AS years_teaching_total
      ,ROUND(m.months_active / 12.0, 2)
         + ROUND(m.months_inactive / 12.0, 2)
         --+ ISNULL(dst.years_full_time_experience, 0)
         AS years_experience_total
FROM months m
--LEFT JOIN gabby.recruiting.applicants dst
--  ON r.salesforce_id = dst.position_number
LEFT JOIN years_teaching_at_kipp y
  ON m.employee_number = y.employee_number
