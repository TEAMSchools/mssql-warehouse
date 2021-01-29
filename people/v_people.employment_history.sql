USE gabby
GO

CREATE OR ALTER VIEW people.employment_history AS

WITH validdates AS (
  SELECT employee_number
        ,associate_id
        ,status_effective_date AS effective_date
  FROM gabby.adp.status_history_clean

  UNION

  SELECT employee_number
        ,associate_id
        ,position_effective_date AS effective_date
  FROM gabby.adp.work_assignment_history_clean

  UNION

  SELECT employee_number
        ,associate_id
        ,regular_pay_effective_date AS effective_date
  FROM gabby.adp.salary_history_clean

  UNION

  SELECT employee_number
        ,associate_id
        ,reports_to_effective_date AS effective_date
  FROM gabby.adp.manager_history_clean
 )

,validranges AS (
  SELECT d.employee_number
        ,d.associate_id
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
      ,r.associate_id
      ,r.effective_start_date
      ,r.effective_end_date

      ,sr.preferred_first_name
      ,sr.preferred_last_name

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
      --,w.job_family_name
      --,w.flsa_status_name

      ,sal.annual_salary
      ,sal.regular_pay_rate_amount
      ,sal.compensation_change_reason_description

      ,mh.reports_to_associate_id

      ,ROW_NUMBER() OVER(
         PARTITION BY r.employee_number
           ORDER BY r.effective_end_date DESC) AS rn_cur
FROM validranges r
JOIN gabby.adp.staff_roster sr
  ON r.employee_number = sr.df_employee_number
LEFT JOIN gabby.adp.status_history_clean s
  ON r.employee_number = s.employee_number
 AND r.effective_start_date BETWEEN s.status_effective_date AND s.status_effective_end_date
LEFT JOIN gabby.adp.work_assignment_history_clean w
  ON r.employee_number = w.employee_number
 AND r.effective_start_date BETWEEN w.position_effective_date AND w.position_effective_end_date
LEFT JOIN gabby.adp.salary_history_clean sal
  ON r.employee_number = sal.employee_number
 AND r.effective_start_date BETWEEN sal.regular_pay_effective_date AND sal.regular_pay_effective_end_date
LEFT JOIN gabby.adp.manager_history_clean mh
  ON r.employee_number = mh.employee_number
 AND r.effective_start_date BETWEEN mh.reports_to_effective_date AND mh.reports_to_effective_end_date
