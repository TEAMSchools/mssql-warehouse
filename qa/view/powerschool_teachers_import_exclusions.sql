USE gabby GO
CREATE OR ALTER VIEW
  qa.powerschool_teachers_import_exclusions AS
WITH
  users_clean AS (
    SELECT
      scw.df_employee_number,
      scw.preferred_name,
      scw.primary_site,
      scw.primary_site_schoolid,
      scw.primary_on_site_department,
      scw.termination_date,
      scw.[status],
      sc.region,
      u.dcid AS users_dcid,
      u.homeschoolid
    FROM
      gabby.people.staff_crosswalk_static scw
      LEFT JOIN gabby.people.school_crosswalk sc ON scw.primary_site = sc.site_name
      AND sc._fivetran_deleted = 0
      LEFT JOIN gabby.powerschool.users u ON scw.ps_teachernumber = u.teachernumber
    COLLATE Latin1_General_BIN
    AND CASE
      WHEN sc.region = 'TEAM Academy Charter School' THEN 'kippnewark'
      WHEN sc.region = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
      WHEN sc.region = 'KIPP Miami' THEN 'kippmiami'
    END = u.[db_name]
  )
SELECT
  *
FROM
  (
    SELECT
      *,
      CASE
        WHEN primary_on_site_department = 'Data' THEN 1
      END AS is_exclude_department,
      CASE
        WHEN DATEDIFF(
          DAY,
          ISNULL(termination_date, CAST(CURRENT_TIMESTAMP AS DATE)),
          CURRENT_TIMESTAMP
        ) > 14 THEN 1
      END AS is_exclude_termination,
      CASE
        WHEN region IS NULL THEN 1
      END AS is_exclude_primarysite,
      CASE
        WHEN primary_site_schoolid <> homeschoolid THEN 1
      END AS is_exclude_homeschoolid
    FROM
      users_clean
  ) sub
WHERE
  CONCAT(
    is_exclude_department,
    is_exclude_homeschoolid,
    is_exclude_primarysite,
    is_exclude_termination
  ) <> ''
