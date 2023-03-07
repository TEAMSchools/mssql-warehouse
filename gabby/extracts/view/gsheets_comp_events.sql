--CREATE OR ALTER VIEW gsheets_comp_events AS
WITH
  approval_pivot AS (
    SELECT
      primary_site,
      legal_entity_name,
      [School Leader] AS school_leader,
      COALESCE(
        [Director School Operations],
        [Director Campus Operations]
      ) AS dso_dco
    FROM
      (
        SELECT
          primary_site,
          legal_entity_name,
          primary_job,
          df_employee_number
        FROM
          people.staff_crosswalk_static
        WHERE
          status != 'TERMINATED'
      ) AS sub PIVOT (
        MAX(df_employee_number) FOR primary_job IN (
          [School Leader],
          [Director School Operations],
          [Director Campus Operations]
        )
      ) AS p
  ),
  school_approval_loops AS (
    SELECT
      l.primary_site,
      l.legal_entity_name,
      l.school_leader,
      l.dso_dco,
      a.userprincipalname AS sl_email,
      a.google_email AS sl_google,
      b.df_employee_number AS hos_ed,
      b.preferred_name AS hos_ed_name,
      b.userprincipalname AS hos_ed_email,
      b.google_email AS hos_ed_google,
      c.df_employee_number AS ed,
      c.preferred_name AS ed_name,
      c.userprincipalname AS ed_email,
      c.google_email AS ed_google,
      d.userprincipalname AS dso_email,
      d.google_email AS dso_google,
      e.df_employee_number AS mdso,
      e.preferred_name AS mdso_name,
      e.userprincipalname AS mdso_email,
      e.google_email AS mdso_google,
      f.df_employee_number AS coo,
      f.preferred_name AS coo_name,
      f.userprincipalname AS coo_email,
      f.google_email AS coo_google
    FROM
      approval_pivot AS l
      /*School Leaders*/
      LEFT JOIN people.staff_crosswalk_static AS a ON (
        l.school_leader = a.df_employee_number
      )
      /*School Leader Managers (HsOS)*/
      LEFT JOIN people.staff_crosswalk_static AS b ON (
        a.manager_df_employee_number = b.df_employee_number
      )
      /*HOS Managers (Executive Directors)*/
      LEFT JOIN people.staff_crosswalk_static AS c ON (
        b.manager_df_employee_number = c.df_employee_number
      )
      /*DSO/DCO*/
      LEFT JOIN people.staff_crosswalk_static AS d ON (l.dso_dco = d.df_employee_number)
      /*DSO/DCO Managers (MDSOs)*/
      LEFT JOIN people.staff_crosswalk_static AS e ON (
        d.manager_df_employee_number = e.df_employee_number
      )
      /*MDSO Managers (COOs)*/
      LEFT JOIN people.staff_crosswalk_static AS f ON (
        e.manager_df_employee_number = f.df_employee_number
      )
  )
SELECT DISTINCT
  x.df_employee_number,
  x.payroll_company_code,
  x.adp_associate_id,
  x.file_number,
  x.primary_job,
  x.primary_site,
  x.primary_on_site_department,
  x.preferred_name,
  x.userprincipalname,
  x.google_email,
  x.status,
  s.region,
  COALESCE(c.campus_name, x.primary_site) AS site_campus,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.hos_ed_email
    WHEN x.primary_on_site_department != 'Operations' THEN l.sl_email
    WHEN x.primary_on_site_department = 'Operations' THEN l.mdso_email
  END AS first_approver_email,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.hos_ed_google
    WHEN x.primary_on_site_department != 'Operations' THEN l.sl_google
    WHEN x.primary_on_site_department = 'Operations' THEN l.mdso_google
  END AS first_approver_google,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.ed_email
    WHEN x.primary_on_site_department != 'Operations' THEN l.hos_ed_email
    WHEN x.primary_on_site_department = 'Operations' THEN l.coo_email
  END AS second_approver_email,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.ed_google
    WHEN x.primary_on_site_department != 'Operations' THEN l.hos_ed_google
    WHEN x.primary_on_site_department = 'Operations' THEN l.coo_google
  END AS second_approver_google,
  l.dso_email AS notify
FROM
  people.staff_crosswalk_static AS x
  LEFT JOIN school_approval_loops AS l ON x.primary_site = l.primary_site
  LEFT JOIN people.school_crosswalk AS s ON x.primary_site = s.site_name
  LEFT JOIN people.campus_crosswalk AS c ON x.primary_site = c.site_name
WHERE
  x.status != 'TERMINATED'
