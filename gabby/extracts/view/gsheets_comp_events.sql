CREATE OR ALTER VIEW
  extracts.gsheets_comp_events AS
WITH
  approval_pivot AS (
    SELECT
      primary_site,
      campus_name,
      legal_entity_name,
      CASE
        WHEN legal_entity_name IN (
          'TEAM Academy Charter School',
          'KIPP Cooper Norcross Academy'
        ) THEN 'KIPP NJ'
        ELSE legal_entity_name
      END AS region,
      [School Leader] AS school_leader,
      COALESCE(
        [Director School Operations],
        [Director Campus Operations]
      ) AS dso_dco
    FROM
      (
        SELECT
          x.primary_site,
          x.legal_entity_name,
          x.primary_job,
          x.df_employee_number,
          c.campus_name
        FROM
          people.staff_crosswalk_static AS x
          LEFT JOIN people.campus_crosswalk AS c ON x.primary_site = c.site_name
        WHERE
          x.status != 'TERMINATED'
          AND x.primary_site NOT IN (
            'Room 11 - 1951 NW 7th Ave',
            'Room 10 - 121 Market St',
            'Room 9 - 60 Park Pl'
          )
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
      COALESCE(l.campus_name, l.primary_site) AS site_campus,
      l.legal_entity_name AS region,
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
      e.google_email AS mdso_google
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
  )
SELECT
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
  x.legal_entity_name,
  l.site_campus,
  l.dso_email AS notify,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.hos_ed_email
    WHEN x.primary_on_site_department != 'Operations' THEN l.sl_email
    WHEN x.primary_on_site_department = 'Operations' THEN 'Approved'
  END AS first_approver_email,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.hos_ed_google
    WHEN x.primary_on_site_department != 'Operations' THEN l.sl_google
    WHEN x.primary_on_site_department = 'Operations' THEN 'Approved'
  END AS first_approver_google,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.ed_email
    WHEN x.primary_on_site_department != 'Operations' THEN l.hos_ed_email
    WHEN l.mdso_email = 'apoole@kippnj.org' THEN 'acorona@kippnj.org'
    WHEN x.primary_on_site_department = 'Operations' THEN l.mdso_email
  END AS second_approver_email,
  CASE
    WHEN x.primary_job IN ('School Leader', 'DSO') THEN l.ed_google
    WHEN x.primary_on_site_department != 'Operations' THEN l.hos_ed_google
    WHEN l.mdso_google = 'apoole@apps.teamschools.org' THEN 'acorona@apps.teamschools.org'
    WHEN x.primary_on_site_department = 'Operations' THEN l.mdso_google
  END AS second_approver_google
FROM
  people.staff_crosswalk_static AS x
  LEFT JOIN school_approval_loops AS l ON (x.primary_site = l.primary_site)
WHERE
  x.status != 'TERMINATED'
  AND x.payroll_company_code != '9AM'
