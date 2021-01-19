USE gabby
GO

CREATE OR ALTER VIEW people.work_assignment_status_history AS

WITH status_clean AS (
  SELECT sub.employee_number
        ,sub.position_status
        ,sub.status_effective_date
        ,COALESCE(sub.status_effective_end_date
                 ,DATEFROMPARTS(CASE
                                 WHEN DATEPART(YEAR, sub.status_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                  AND DATEPART(MONTH, sub.status_effective_date) >= 7
                                      THEN DATEPART(YEAR, sub.status_effective_date) + 1
                                 ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                END, 6, 30)) AS status_effective_end_date
  FROM
      (
       SELECT sh.associate_id
             ,sh.position_status
             ,CONVERT(DATE, sh.status_effective_date) AS status_effective_date
             ,CONVERT(DATE, sh.status_effective_end_date) AS status_effective_end_date

             ,sr.df_employee_number AS employee_number
       FROM gabby.adp.status_history sh
       JOIN gabby.adp.staff_roster sr
         ON sh.associate_id = sr.adp_associate_id
      ) sub
 )

,work_assignment_clean AS (
  SELECT sub.employee_number
        ,sub.business_unit_description
        ,sub.location_description
        ,sub.home_department_description
        ,sub.job_title_description
        --,sub.job_family_name
        --,sub.flsa_status_name
        ,sub.position_effective_date
        ,COALESCE(sub.position_effective_end_date
                 ,DATEFROMPARTS(CASE 
                                 WHEN DATEPART(YEAR,sub.position_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                  AND DATEPART(MONTH,sub.position_effective_date) >= 7 
                                      THEN DATEPART(YEAR,sub.position_effective_date) + 1
                                 ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                END, 6, 30)) AS position_effective_end_date
  FROM
      (
       SELECT wah.associate_id
             ,wah.job_title_description
             ,wah.business_unit_description
             ,wah.home_department_description
             ,wah.location_description
             ,CONVERT(DATE, wah.position_effective_date) AS position_effective_date
             ,CONVERT(DATE, wah.position_effective_end_date) AS position_effective_end_date

             ,sr.df_employee_number AS employee_number
       FROM gabby.adp.work_assignment_history wah
       JOIN gabby.adp.staff_roster sr
         ON wah.associate_id = sr.adp_associate_id
      ) sub
 )

,validdates AS (
  SELECT employee_number
        ,status_effective_date AS effective_date
  FROM status_clean
  
  UNION
  
  SELECT employee_number
        ,position_effective_date AS effective_date
  FROM work_assignment_clean
 )

,validranges AS (
  SELECT d.employee_number
        ,d.effective_date AS effective_start_date
        ,COALESCE(DATEADD(DAY, -1, LEAD(d.effective_date, 1) OVER(PARTITION BY d.employee_number ORDER BY d.effective_date))
                 ,DATEFROMPARTS(CASE
                                 WHEN DATEPART(YEAR,d.effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                  AND DATEPART(MONTH,d.effective_date) >= 7
                                      THEN DATEPART(YEAR,d.effective_date) + 1
                                 ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                END, 6, 30)) AS effective_end_date
  FROM validdates d
 )

SELECT r.employee_number
      ,r.effective_start_date
      ,r.effective_end_date

      ,sr.preferred_first_name AS first_name
      ,sr.preferred_last_name AS last_name

      ,s.position_status
      --,s.base_salary

      ,w.business_unit_description AS business_unit
      ,w.location_description AS [location]
      ,w.home_department_description home_department
      ,w.job_title_description AS job_title
      --,w.job_family_name
      --,w.flsa_status_name

      ,ROW_NUMBER() OVER(
         PARTITION BY r.employee_number
           ORDER BY r.effective_end_date DESC) AS rn_cur
FROM validranges r
JOIN gabby.adp.staff_roster sr
  ON r.employee_number = sr.df_employee_number
LEFT JOIN status_clean s
  ON r.employee_number = s.employee_number
 AND r.effective_start_date BETWEEN s.status_effective_date AND s.status_effective_end_date
LEFT JOIN work_assignment_clean w
  ON r.employee_number = w.employee_number
 AND r.effective_start_date BETWEEN w.position_effective_date AND w.position_effective_end_date
