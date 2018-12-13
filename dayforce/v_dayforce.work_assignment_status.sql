USE gabby
GO

CREATE OR ALTER VIEW dayforce.work_assignment_status AS

WITH eofy AS (
  SELECT DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 6, 30) AS fy_end_date
)

,status_clean AS (
  SELECT number AS df_employee_id
        ,first_name
        ,last_name
        ,status
        ,base_salary
        ,CASE
          WHEN status = 'Terminated' THEN DATEADD(DAY, 1, CONVERT(DATE,effective_start))
          ELSE CONVERT(DATE,effective_start)
         END AS effective_start
        ,COALESCE(CONVERT(DATE,effective_end), (SELECT eofy.fy_end_date FROM eofy)) AS effective_end
  FROM gabby.dayforce.employee_status
 )

,work_assignment_clean AS (
  SELECT employee_reference_code AS df_employee_id
        ,job_family_name
        ,legal_entity_name
        ,physical_location_name
        ,department_name
        ,job_name
        ,flsa_status_name
        ,CONVERT(DATE,work_assignment_effective_start) AS work_assignment_effective_start
        ,COALESCE(CONVERT(DATE,work_assignment_effective_end), (SELECT eofy.fy_end_date FROM eofy)) AS work_assignment_effective_end
  FROM gabby.dayforce.employee_work_assignment
  WHERE primary_work_assignment = 1
)

,validdates AS (
  SELECT df_employee_id
        ,effective_start AS effective_date
  FROM status_clean
  
  UNION
  
  SELECT df_employee_id
        ,work_assignment_effective_start AS effective_date
  FROM work_assignment_clean
 )

,validranges AS (
  SELECT d.df_employee_id
        ,d.effective_date AS effective_start_date
        ,DATEADD(DAY, -1, LEAD(d.effective_date, 1, (SELECT eofy.fy_end_date FROM eofy)) OVER(PARTITION BY d.df_employee_id ORDER BY d.effective_date)) AS effective_end_date
  FROM validdates d
 )

SELECT r.df_employee_id
      ,r.effective_start_date
      ,r.effective_end_date

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
FROM validranges r
LEFT JOIN status_clean s
  ON r.df_employee_id = s.df_employee_id
 AND r.effective_start_date BETWEEN s.effective_start AND s.effective_end
LEFT JOIN work_assignment_clean w
  ON r.df_employee_id = w.df_employee_id
 AND r.effective_end_date BETWEEN w.work_assignment_effective_start AND w.work_assignment_effective_end