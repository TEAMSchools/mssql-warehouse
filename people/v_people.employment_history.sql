USE gabby
GO

CREATE OR ALTER VIEW people.employment_history AS

WITH validdates AS (
  SELECT employee_number
        ,associate_id
        ,position_id
        ,file_number
        ,source_system
        ,status_effective_date AS effective_start_date
  FROM gabby.people.status_history_static

  UNION

  SELECT employee_number
        ,associate_id
        ,position_id
        ,file_number
        ,source_system
        ,position_effective_date
  FROM gabby.people.work_assignment_history_static

  UNION

  SELECT employee_number
        ,associate_id
        ,position_id
        ,file_number
        ,source_system
        ,regular_pay_effective_date
  FROM gabby.people.salary_history_static

  UNION

  SELECT employee_number
        ,associate_id
        ,position_id
        ,file_number
        ,source_system
        ,reports_to_effective_date
  FROM gabby.people.manager_history_static
 )

,validranges AS (
  SELECT d.employee_number
        ,d.associate_id
        ,d.position_id
        ,d.file_number
        ,d.source_system
        ,d.effective_start_date
        ,COALESCE(DATEADD(DAY, -1, LEAD(d.effective_start_date, 1) OVER(PARTITION BY d.position_id ORDER BY d.effective_start_date))
                 ,CASE WHEN d.source_system = 'DF' THEN '2020-12-31' END /* close out DF records */
                 ,DATEFROMPARTS(CASE
                                 WHEN DATEPART(YEAR,d.effective_start_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                  AND DATEPART(MONTH,d.effective_start_date) >= 7
                                      THEN DATEPART(YEAR,d.effective_start_date) + 1
                                 WHEN DATEPART(YEAR, GETDATE()) = gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                  AND DATEPART(MONTH, GETDATE()) >= 7
                                      THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 2
                                 ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                END, 6, 30)) AS effective_end_date
  FROM validdates d
 )

SELECT r.employee_number
      ,r.associate_id
      ,r.position_id
      ,r.file_number
      ,r.effective_start_date
      ,r.effective_end_date
      ,CASE WHEN GETDATE() BETWEEN r.effective_start_date AND r.effective_end_date THEN 1 END AS is_current_record

      ,s.position_status
      ,s.termination_reason_description AS termination_reason
      ,s.leave_reason_description AS leave_reason
      ,s.paid_leave_of_absence
      ,s.status_effective_date AS status_effective_start_date
      ,s.status_effective_end_date
      ,LAG(s.position_status, 1) OVER(PARTITION BY r.position_id ORDER BY r.effective_start_date) AS position_status_prev
      ,MAX(CASE 
            WHEN CONVERT(DATE, GETDATE()) BETWEEN s.status_effective_date AND s.status_effective_end_date
                   THEN s.position_status
           END) OVER(PARTITION BY r.associate_id) AS position_status_cur

      ,w.business_unit_code
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
      ,mh.reports_to_employee_number
FROM validranges r
LEFT JOIN gabby.people.status_history_static s
  ON r.position_id = s.position_id
 AND r.effective_start_date BETWEEN s.status_effective_date AND s.status_effective_end_date_eoy
LEFT JOIN gabby.people.work_assignment_history_static w
  ON r.position_id = w.position_id
 AND r.effective_start_date BETWEEN w.position_effective_date AND w.position_effective_end_date_eoy
LEFT JOIN gabby.people.salary_history_static sal
  ON r.position_id = sal.position_id
 AND r.effective_start_date BETWEEN sal.regular_pay_effective_date AND sal.regular_pay_effective_end_date_eoy
LEFT JOIN gabby.people.manager_history_static mh
  ON r.position_id = mh.position_id
 AND r.effective_start_date BETWEEN mh.reports_to_effective_date AND mh.reports_to_effective_end_date_eoy
