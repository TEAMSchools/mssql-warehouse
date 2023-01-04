CREATE OR ALTER VIEW
  extracts.gsheets_staff_roster AS
SELECT
  adp_associate_id AS associate_id,
  preferred_first_name,
  preferred_last_name,
  preferred_name AS preferred_lastfirst,
  primary_site AS [location],
  primary_site AS location_custom,
  primary_on_site_department AS department,
  primary_on_site_department AS subject_dept_custom,
  primary_job AS job_title,
  primary_job AS job_title_custom,
  manager_name AS reports_to,
  manager_adp_associate_id AS manager_custom_assoc_id,
  [status] AS position_status,
  CAST(termination_date AS NVARCHAR) AS termination_date,
  mail AS email_addr,
  CAST(
    COALESCE(rehire_date, original_hire_date) AS NVARCHAR
  ) AS hire_date,
  CAST(
    work_assignment_start_date AS NVARCHAR
  ) AS position_start_date,
  df_employee_number,
  manager_df_employee_number,
  legal_entity_name,
  userprincipalname,
  file_number,
  position_id,
  last_name + ', ' + first_name AS legal_name,
  mobile_number
FROM
  gabby.people.staff_crosswalk_static
