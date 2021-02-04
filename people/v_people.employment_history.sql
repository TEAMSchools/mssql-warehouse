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

SELECT r.employee_number
      ,r.associate_id
      ,r.position_id
      ,r.effective_start_date
      ,r.effective_end_date

      ,s.position_status
      ,s.termination_reason_description AS termination_reason
      ,s.leave_reason_description AS leave_reason
      ,s.paid_leave_of_absence
      ,MIN(s.status_effective_date) OVER(PARTITION BY r.associate_id) AS original_hire_date

      ,w.business_unit_description AS business_unit
      ,w.location_description AS [location]
      ,w.home_department_description AS home_department
      ,w.job_title_code
      ,w.job_title_description AS job_title
      ,w.job_change_reason_code
      ,w.job_change_reason_description AS job_change_reason
      ,w.position_effective_date AS position_effective_start_date
      ,w.position_effective_end_date

      ,sal.annual_salary
      ,sal.regular_pay_rate_amount
      ,sal.compensation_change_reason_description AS compensation_change_reason

      ,mh.reports_to_associate_id
FROM validranges r
LEFT JOIN gabby.adp.status_history_clean s
  ON r.position_id = s.position_id
 AND r.effective_start_date BETWEEN s.status_effective_date AND s.status_effective_end_date_eoy
LEFT JOIN gabby.adp.work_assignment_history_clean w
  ON r.position_id = w.position_id
 AND r.effective_start_date BETWEEN w.position_effective_date AND w.position_effective_end_date_eoy
LEFT JOIN gabby.adp.salary_history_clean sal
  ON r.position_id = sal.position_id
 AND r.effective_start_date BETWEEN sal.regular_pay_effective_date AND sal.regular_pay_effective_end_date_eoy
LEFT JOIN gabby.adp.manager_history_clean mh
  ON r.position_id = mh.position_id
 AND r.effective_start_date BETWEEN mh.reports_to_effective_date AND mh.reports_to_effective_end_date_eoy
