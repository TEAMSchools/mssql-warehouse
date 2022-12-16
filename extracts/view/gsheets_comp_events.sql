CREATE OR ALTER VIEW
  extracts.gsheets_comp_events AS
WITH
  school_approvers AS (
    SELECT
      x.primary_site,
      x.userprincipalname AS first_approver_email,
      x.manager_userprincipalname AS second_approver_email,
      x.google_email AS first_approver_google,
      m.google_email AS second_approver_google
    FROM
      gabby.people.staff_crosswalk_static AS x
      LEFT JOIN gabby.people.staff_crosswalk_static AS m ON x.manager_df_employee_number = m.df_employee_number
    WHERE
      x.primary_job = 'School Leader'
      AND x.status != 'TERMINATED'
  ),
  ktaf_approvers AS (
    SELECT
      x.df_employee_number,
      x.manager_df_employee_number,
      m.google_email AS first_approver_google,
      m.userprincipalname AS first_approver_email,
      gm.google_email AS second_approver_google,
      gm.userprincipalname AS second_approver_email
    FROM
      gabby.people.staff_crosswalk_static AS x
      LEFT JOIN gabby.people.staff_crosswalk_static AS m ON x.manager_df_employee_number = m.df_employee_number
      LEFT JOIN gabby.people.staff_crosswalk_static AS gm ON m.manager_df_employee_number = gm.df_employee_number
    WHERE
      x.primary_job != 'School Leader'
  )
SELECT
  x.payroll_company_code,
  x.legal_entity_name,
  CONCAT(x.preferred_name, ' - ', x.primary_site) AS preferred_name,
  x.file_number,
  x.primary_site,
  x.primary_on_site_department,
  x.primary_job,
  x.google_email,
  x.userprincipalname,
  COALESCE(
    s.first_approver_google,
    k.first_approver_google
  ) AS first_approver,
  COALESCE(
    s.second_approver_google,
    k.second_approver_google
  ) AS second_approver,
  COALESCE(
    s.first_approver_email,
    k.first_approver_email
  ) AS first_approver_email,
  COALESCE(
    s.second_approver_email,
    k.second_approver_email
  ) AS second_approver_email
FROM
  gabby.people.staff_crosswalk_static AS x
  LEFT JOIN school_approvers AS s ON x.primary_site = s.primary_site
  LEFT JOIN ktaf_approvers AS k ON x.df_employee_number = k.df_employee_number
WHERE
  x.status != 'TERMINATED'
