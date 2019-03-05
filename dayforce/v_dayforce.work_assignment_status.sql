USE gabby
GO

CREATE OR ALTER VIEW dayforce.work_assignment_status AS

WITH status_clean AS (
  SELECT sub.df_employee_id
        ,sub.first_name
        ,sub.last_name
        ,sub.status
        ,sub.base_salary
        ,sub.effective_start
        ,COALESCE(sub.effective_end
                 ,DATEFROMPARTS(CASE 
                                 WHEN DATEPART(MONTH,sub.effective_start) >= 7 THEN DATEPART(YEAR,sub.effective_start) + 1
                                 ELSE DATEPART(YEAR,sub.effective_start)
                                END, 6, 30)) AS effective_end
  FROM
      (
       SELECT number AS df_employee_id
             ,first_name
             ,last_name
             ,status
             ,base_salary
             ,CASE
               WHEN status = 'Terminated' THEN DATEADD(DAY, 1, CONVERT(DATE,effective_start))
               ELSE CONVERT(DATE,effective_start)
              END AS effective_start
             ,CONVERT(DATE,effective_end) AS effective_end
       FROM gabby.dayforce.employee_status
      ) sub
 )

,work_assignment_clean AS (
  SELECT sub.df_employee_id
        ,sub.job_family_name
        ,sub.legal_entity_name
        ,sub.physical_location_name
        ,sub.department_name
        ,sub.job_name
        ,sub.flsa_status_name
        ,sub.work_assignment_effective_start
        ,COALESCE(sub.work_assignment_effective_end
                 ,DATEFROMPARTS(CASE 
                                 WHEN DATEPART(MONTH,sub.work_assignment_effective_start) >= 7 THEN DATEPART(YEAR,sub.work_assignment_effective_start) + 1
                                 ELSE DATEPART(YEAR,sub.work_assignment_effective_start)
                                END, 6, 30)) AS work_assignment_effective_end
  FROM
      (
       SELECT employee_reference_code AS df_employee_id
             ,job_family_name
             ,legal_entity_name
             ,physical_location_name
             ,department_name
             ,job_name
             ,flsa_status_name
             ,CONVERT(DATE,work_assignment_effective_start) AS work_assignment_effective_start
             ,CONVERT(DATE,work_assignment_effective_end) AS work_assignment_effective_end
       FROM gabby.dayforce.employee_work_assignment
       WHERE primary_work_assignment = 1
      ) sub
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
        ,COALESCE(DATEADD(DAY, -1, LEAD(d.effective_date, 1) OVER(PARTITION BY d.df_employee_id ORDER BY d.effective_date))
                 ,DATEFROMPARTS(CASE 
                                 WHEN DATEPART(MONTH,d.effective_date) >= 7 THEN DATEPART(YEAR,d.effective_date) + 1
                                 ELSE DATEPART(YEAR,d.effective_date)
                                END, 6, 30)) AS effective_end_date
  FROM validdates d
 )

SELECT r.df_employee_id
      ,r.effective_start_date
      ,r.effective_end_date

      ,sr.preferred_first_name AS first_name
      ,sr.preferred_last_name AS last_name
      
      ,s.status
      ,s.base_salary

      ,w.job_family_name
      ,w.legal_entity_name
      ,w.physical_location_name
      ,w.department_name
      ,w.job_name
      ,w.flsa_status_name
FROM validranges r
JOIN gabby.dayforce.staff_roster sr
  ON r.df_employee_id = sr.df_employee_number
LEFT JOIN status_clean s
  ON r.df_employee_id = s.df_employee_id
 AND r.effective_start_date BETWEEN s.effective_start AND s.effective_end
LEFT JOIN work_assignment_clean w
  ON r.df_employee_id = w.df_employee_id
 AND r.effective_start_date BETWEEN w.work_assignment_effective_start AND w.work_assignment_effective_end