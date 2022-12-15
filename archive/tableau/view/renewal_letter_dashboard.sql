USE gabby GO
CREATE OR ALTER VIEW
  tableau.renewal_letter_dashboard AS
WITH
  wf AS (
    SELECT
      affected_employee_number,
      renewal_status_updated,
      renewal_status,
      YEAR(renewal_status_updated) AS renewal_year,
      ROW_NUMBER() OVER (
        PARTITION BY
          affected_employee_number,
          YEAR(renewal_status_updated)
        ORDER BY
          renewal_status_updated DESC
      ) AS rn_recent_workflow
    FROM
      (
        SELECT
          rs.employee_reference_code AS affected_employee_number,
          CAST(
            rs.workflow_data_last_modified_timestamp AS DATETIME2
          ) AS renewal_status_updated,
          CASE
            WHEN rs.workflow_status = 'completed'
            AND rs.workflow_data_saved = 1 THEN 'Offer Accepted'
            WHEN rs.workflow_status = 'completed'
            AND rs.workflow_data_saved = 0 THEN 'SL, HR, or Employee Rejected'
            WHEN rs.workflow_status = 'open'
            AND rs.workflow_data_saved = 0 THEN 'Pending Acceptance'
            WHEN rs.workflow_status = 'withdrawn'
            AND rs.workflow_data_saved = 0 THEN 'DSO Withdrew Letter'
          END AS renewal_status
        FROM
          gabby.dayforce.renewal_status rs
      ) sub
  ),
  was AS (
    SELECT
      df_employee_number,
      future_work_assignment_effective_start,
      future_role,
      future_department,
      future_location,
      future_legal_entity,
      future_job_family,
      ROW_NUMBER() OVER (
        PARTITION BY
          df_employee_number
        ORDER BY
          future_work_assignment_effective_start DESC
      ) AS rn_recent_work_assignment
    FROM
      (
        SELECT
          was.employee_reference_code AS df_employee_number,
          was.job_family_name AS future_job_family,
          was.legal_entity_name AS future_legal_entity,
          was.physical_location_name AS future_location,
          was.department_name AS future_department,
          was.job_name AS future_role,
          CAST(
            CASE
              WHEN work_assignment_effective_start <> '' THEN work_assignment_effective_start
            END AS DATE
          ) AS future_work_assignment_effective_start
        FROM
          gabby.dayforce.employee_work_assignment was
        WHERE
          was.primary_work_assignment = 1
      ) sub
  ),
  sta AS (
    SELECT
      df_employee_number,
      future_status,
      future_salary,
      future_status_effective_start,
      ROW_NUMBER() OVER (
        PARTITION BY
          df_employee_number
        ORDER BY
          future_status_effective_start DESC
      ) AS rn_recent_status
    FROM
      (
        SELECT
          sta.number AS df_employee_number,
          sta.[status] AS future_status,
          sta.base_salary AS future_salary,
          CAST(sta.effective_start AS DATE) AS future_status_effective_start
        FROM
          gabby.dayforce.employee_status sta
      ) sub
  )
SELECT
  r.df_employee_number,
  r.preferred_name,
  r.manager_name AS current_manager_name,
  r.[status] AS current_status,
  r.legal_entity_name AS current_legal_entity,
  r.primary_site AS current_site,
  r.primary_on_site_department AS current_department,
  r.primary_job AS current_role,
  r.is_regional_staff AS is_regional_staff_current,
  wf.renewal_status,
  wf.renewal_status_updated,
  wf.renewal_year,
  wf.rn_recent_workflow,
  was.future_legal_entity,
  was.future_location,
  was.future_department,
  was.future_job_family,
  was.future_role,
  was.future_work_assignment_effective_start,
  sta.future_status,
  sta.future_salary,
  sta.future_status_effective_start
FROM
  dayforce.staff_roster r
  LEFT JOIN wf ON r.df_employee_number = wf.affected_employee_number
  LEFT JOIN was ON r.df_employee_number = was.df_employee_number
  AND was.rn_recent_work_assignment = 1
  LEFT JOIN sta ON r.df_employee_number = sta.df_employee_number
  AND sta.rn_recent_status = 1
