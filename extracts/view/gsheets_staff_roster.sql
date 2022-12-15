USE gabby GO
CREATE OR ALTER VIEW
  extracts.gsheets_staff_roster AS
SELECT
  df.adp_associate_id AS associate_id,
  df.preferred_first_name,
  df.preferred_last_name,
  df.preferred_name AS preferred_lastfirst,
  df.primary_site AS [location],
  df.primary_site AS location_custom,
  df.primary_on_site_department AS department,
  df.primary_on_site_department AS subject_dept_custom,
  df.primary_job AS job_title,
  df.primary_job AS job_title_custom,
  df.manager_name AS reports_to,
  df.manager_adp_associate_id AS manager_custom_assoc_id,
  df.[status] AS position_status,
  CAST(df.termination_date AS NVARCHAR) AS termination_date,
  df.mail AS email_addr,
  CAST(
    COALESCE(df.rehire_date, df.original_hire_date) AS NVARCHAR
  ) AS hire_date,
  CAST(df.work_assignment_start_date AS NVARCHAR) AS position_start_date,
  df.df_employee_number,
  df.manager_df_employee_number,
  df.legal_entity_name,
  df.userprincipalname,
  df.file_number,
  df.position_id,
  df.last_name + ', ' + df.first_name AS legal_name,
  df.mobile_number
FROM
  gabby.people.staff_crosswalk_static AS df
