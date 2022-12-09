USE gabby GO
CREATE OR ALTER VIEW
  tableau.staff_job_salary_audit AS
SELECT
  h.employee_number,
  h.associate_id,
  h.effective_start_date,
  h.effective_end_date,
  h.home_department,
  h.job_title,
  h.job_change_reason,
  h.annual_salary,
  h.compensation_change_reason,
  LAG(h.home_department, 1) OVER (
    PARTITION BY
      h.employee_number
    ORDER BY
      h.effective_start_date ASC
  ) AS prev_home_department,
  LAG(h.job_title, 1) OVER (
    PARTITION BY
      h.employee_number
    ORDER BY
      h.effective_start_date ASC
  ) AS prev_job_title,
  LAG(h.annual_salary, 1) OVER (
    PARTITION BY
      h.employee_number
    ORDER BY
      h.effective_start_date ASC
  ) AS prev_annual_salary,
  h.is_current_record
  /* dedupe positions */
,
  ROW_NUMBER() OVER (
    PARTITION BY
      h.associate_id
    ORDER BY
      h.primary_position DESC,
      h.status_effective_start_date DESC,
      CASE
        WHEN h.position_status = 'Terminated' THEN 0
        ELSE 1
      END DESC,
      h.effective_start_date DESC
  ) AS rn_position,
  r.preferred_first_name,
  r.preferred_last_name,
  r.manager_name,
  r.legal_entity_name,
  r.primary_site,
  r.[status],
  ROW_NUMBER() OVER (
    PARTITION BY
      h.employee_number
    ORDER BY
      h.effective_start_date DESC
  ) AS rn_curr
FROM
  gabby.people.employment_history_static h
  JOIN gabby.people.staff_crosswalk_static r ON h.associate_id = r.adp_associate_id
WHERE
  (
    h.job_title IS NOT NULL
    OR h.annual_salary IS NOT NULL
  )
