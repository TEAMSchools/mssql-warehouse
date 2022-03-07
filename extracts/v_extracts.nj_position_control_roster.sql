USE gabby
GO


CREATE OR ALTER VIEW extracts.nj_position_control_roster AS

SELECT sr.preferred_first_name
      ,sr.preferred_last_name
      ,sr.original_hire_date
      ,sr.employee_number
      ,sr.file_number
      ,sr.[location]
      ,sr.business_unit
      ,sr.job_title AS adp_job_title
      ,'N/A' AS substitute_teacher
      ,sr.flsa AS overtime_control_number
      ,'N/A' AS extra_pay_control_number
      ,'N/A' AS position_tracking
      ,'N/A' AS retirement_projection
      ,sr.annual_salary AS base_salary 
      ,sr.work_assignment_start_date
      ,sr.worker_category AS ft_pt
      ,DATEDIFF(YEAR, sr.work_assignment_start_date, GETDATE()) AS longevity
      ,CASE
        WHEN sr.worker_category LIKE '%part%' THEN 0.5 
        ELSE 1.0 
       END AS FTE
      --Aliasing CEO/CFO for report terminology--
      ,CASE 
       WHEN sr.job_title = 'Chief Financial Officer' THEN 'School business administrator'
       WHEN sr.job_title = 'Chief Executive Officer' THEN 'Superintendent'
       ELSE sr.job_title
       END AS report_job_title
FROM gabby.people.staff_roster sr
WHERE job_title IN ('Chief Executive Officer','Chief Financial Officer') OR sr.business_unit IN ('TEAM Academy Charter School','KIPP Cooper Norcross Academy') AND sr.position_status IN ('Active','Leave')

