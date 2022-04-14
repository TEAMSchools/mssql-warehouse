USE gabby
GO

CREATE OR ALTER VIEW tableau.nj_position_control_roster AS

WITH pivot_table AS (
  SELECT position_id
        ,[Medical]
        ,[Dental]
        ,[Vision]
  FROM
      (
       SELECT position_id
             ,plan_type
             ,plan_name
       FROM adp.comprehensive_benefits_report
      ) AS source_table

  PIVOT (
    MAX(plan_name)
    FOR plan_type IN ([Medical],[Dental],[Vision])
   ) AS pivot_table
)

,cost_number AS (
  SELECT associate_id
        ,gabby.dbo.GROUP_CONCAT(custom_area_3) AS grant_number
        ,gabby.dbo.GROUP_CONCAT(cost_number) AS cost_number
  FROM adp.restricted_grant_coding
  GROUP BY associate_id
)

SELECT sr.first_name
      ,sr.last_name
      ,sr.original_hire_date
      ,sr.employee_number
      ,sr.file_number
      ,sr.position_id
      ,sr.[location]
      ,sr.business_unit
      ,sr.job_title AS adp_job_title
      ,sr.flsa AS overtime_control_number
      ,sr.annual_salary AS base_salary 
      ,sr.work_assignment_start_date
      ,sr.worker_category AS ft_pt
      ,DATEDIFF(YEAR, sr.work_assignment_start_date, GETDATE()) AS longevity
      ,CASE WHEN sr.worker_category LIKE '%part%' THEN 0.5 ELSE 1.0 END AS fte
      /*Aliasing CEO/CFO for report terminology */
      ,CASE 
        WHEN sr.job_title = 'Chief Financial Officer' THEN 'School Business Administrator'
        WHEN sr.job_title = 'Chief Executive Officer' THEN 'Superintendent'
        ELSE sr.job_title
       END AS report_job_title
      
      ,pvt.Medical
      ,pvt.Dental
      ,pvt.Vision

      ,cn.cost_number
      ,cn.grant_number

      ,'N/A' AS substitute_teacher
      ,'N/A' AS extra_pay_control_number
      ,'N/A' AS position_tracking
      ,'N/A' AS retirement_projection
FROM gabby.people.staff_roster sr
LEFT JOIN pivot_table pvt
  ON sr.position_id = pvt.position_id
LEFT JOIN cost_number cn
  ON sr.associate_id = cn.associate_id
WHERE sr.position_status IN ('Active','Leave')
  AND (job_title IN ('Chief Executive Officer','Chief Financial Officer')
         OR sr.business_unit IN ('TEAM Academy Charter School','KIPP Cooper Norcross Academy'))
ORDER BY employee_number