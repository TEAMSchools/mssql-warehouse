USE gabby
GO

CREATE OR ALTER VIEW people.employment_history AS

WITH validdates AS (
  SELECT employee_number
        ,associate_id
        ,position_id
        ,status_effective_date AS effective_date
  FROM gabby.adp.status_history_clean

  UNION

  SELECT employee_number
        ,associate_id
        ,position_id
        ,position_effective_date AS effective_date
  FROM gabby.adp.work_assignment_history_clean

  UNION

  SELECT employee_number
        ,associate_id
        ,position_id
        ,regular_pay_effective_date AS effective_date
  FROM gabby.adp.salary_history_clean

  UNION

  SELECT employee_number
        ,associate_id
        ,position_id
        ,reports_to_effective_date AS effective_date
  FROM gabby.adp.manager_history_clean
 )

,validranges AS (
  SELECT d.employee_number
        ,d.associate_id
        ,d.position_id
        ,d.effective_date AS effective_start_date
        ,COALESCE(DATEADD(DAY, -1, LEAD(d.effective_date, 1) OVER(PARTITION BY d.position_id ORDER BY d.effective_date))
                 ,DATEFROMPARTS(CASE
                                 WHEN DATEPART(YEAR,d.effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                  AND DATEPART(MONTH,d.effective_date) >= 7
                                      THEN DATEPART(YEAR,d.effective_date) + 1
                                 ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                END, 6, 30)) AS effective_end_date
  FROM validdates d
 )

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.effective_start_date
      ,sub.effective_end_date
      ,sub.position_status
      ,sub.termination_reason_description
      ,sub.leave_reason_description
      ,sub.paid_leave_of_absence
      ,sub.business_unit_description
      ,sub.location_description
      ,sub.home_department_description
      ,sub.job_title_code
      ,sub.job_title_description
      ,sub.job_change_reason_code
      ,sub.job_change_reason_description
      ,sub.annual_salary
      ,sub.regular_pay_rate_amount
      ,sub.compensation_change_reason_description
      ,sub.reports_to_associate_id

      ,COALESCE(ea.preferred_name, ea.first_name) AS preferred_first_name
      ,COALESCE(df.preferred_last_name, ea.last_name) AS preferred_last_name
      --job_family_name
      --flsa_status_name
FROM
    (
     SELECT r.employee_number
           ,r.associate_id
           ,r.position_id
           ,r.effective_start_date
           ,r.effective_end_date

           ,s.position_status
           ,s.termination_reason_description
           ,s.leave_reason_description
           ,s.paid_leave_of_absence

           ,w.business_unit_description
           ,w.location_description
           ,w.home_department_description
           ,w.job_title_code
           ,w.job_title_description
           ,w.job_change_reason_code
           ,w.job_change_reason_description

           ,sal.annual_salary
           ,sal.regular_pay_rate_amount
           ,sal.compensation_change_reason_description

           ,mh.reports_to_associate_id
     FROM validranges r
     LEFT JOIN gabby.adp.status_history_clean s
       ON r.position_id = s.position_id
      AND r.effective_start_date BETWEEN s.status_effective_date AND s.status_effective_end_date
     LEFT JOIN gabby.adp.work_assignment_history_clean w
       ON r.position_id = w.position_id
      AND r.effective_start_date BETWEEN w.position_effective_date AND w.position_effective_end_date
     LEFT JOIN gabby.adp.salary_history_clean sal
       ON r.position_id = sal.position_id
      AND r.effective_start_date BETWEEN sal.regular_pay_effective_date AND sal.regular_pay_effective_end_date
     LEFT JOIN gabby.adp.manager_history_clean mh
       ON r.position_id = mh.position_id
      AND r.effective_start_date BETWEEN mh.reports_to_effective_date AND mh.reports_to_effective_end_date
    ) sub
JOIN gabby.adp.employees_all ea
  ON sub.employee_number = ea.file_number
LEFT JOIN gabby.dayforce.employees df
  ON ea.file_number = df.df_employee_number
