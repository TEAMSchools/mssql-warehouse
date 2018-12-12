USE gabby
GO

--CREATE OR ALTER VIEW dayforce.work_assignment_status AS

with validdates AS (
  SELECT number AS df_employee_id
        ,CONVERT(DATETIME,LEFT(effective_start,10)) AS date
  FROM gabby.dayforce.employee_status
  
  UNION
  
  SELECT number AS df_employee_id
        ,CONVERT(DATETIME,LEFT(effective_end,10)) AS date
  FROM gabby.dayforce.employee_status

  UNION

  SELECT employee_reference_code AS df_employee_id
        ,CONVERT(DATETIME,work_assignment_effective_start) AS date
  FROM gabby.dayforce.employee_work_assignment

  UNION

  SELECT employee_reference_code AS df_employee_id
        ,CONVERT(DATETIME,work_assignment_effective_end) AS date
  FROM gabby.dayforce.employee_work_assignment
  )

,validranges AS (
  SELECT d.df_employee_id
       ,d.date AS effective_start
       ,lead(d.date,1) over (partition by d.df_employee_id order by d.date) AS effective_end
  FROM validdates d
  )

SELECT r.df_employee_id
      ,r.effective_start
      ,r.effective_end
      ,s.first_name
      ,s.last_name
      ,s.status
      ,s.base_salary
      ,w.job_family_name
      ,w.legal_entity_name
      ,w.physical_location_name
      ,w.department_name
      ,w.job_name
      ,w.flsa_status_name
FROM validranges r JOIN gabby.dayforce.employee_status s
  ON r.df_employee_id = s.number
 AND COALESCE(r.effective_end,CONVERT(DATETIME,GETDATE())) > CONVERT(DATETIME,LEFT(s.effective_start,10))
 AND r.effective_start < COALESCE(CONVERT(DATETIME,LEFT(s.effective_end,10)),CONVERT(DATETIME,GETDATE()))

     JOIN gabby.dayforce.employee_work_assignment w
  ON r.df_employee_id = w.employee_reference_code
 AND COALESCE(r.effective_end,CONVERT(DATETIME,GETDATE())) > w.work_assignment_effective_start
 AND r.effective_start < COALESCE(w.work_assignment_effective_end,CONVERT(DATETIME,GETDATE()))
 AND w.primary_work_assignment = 1