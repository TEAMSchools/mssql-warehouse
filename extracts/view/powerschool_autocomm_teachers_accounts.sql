CREATE OR ALTER VIEW
  extracts.powerschool_autocomm_teachers_accounts AS
WITH
  users_union AS (
    /* existing users, DF schoolid matches PS homeschoolid */
    SELECT
      scw.ps_teachernumber,
      scw.preferred_first_name,
      scw.preferred_last_name,
      scw.primary_site,
      scw.primary_site_schoolid,
      scw.primary_on_site_department,
      scw.birth_date,
      scw.termination_date,
      scw.samaccountname,
      scw.mail,
      scw.[status],
      sc.region
    FROM
      gabby.people.staff_crosswalk_static AS scw
      INNER JOIN gabby.people.school_crosswalk AS sc ON (
        scw.primary_site = sc.site_name
        AND sc._fivetran_deleted = 0
      )
      INNER JOIN gabby.powerschool.users AS u ON (
        (
          scw.ps_teachernumber = u.teachernumber
          COLLATE LATIN1_GENERAL_BIN
        )
        AND scw.primary_site_schoolid = u.homeschoolid
        AND CASE
          WHEN sc.region = 'TEAM Academy Charter School' THEN 'kippnewark'
          WHEN sc.region = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
          WHEN sc.region = 'KIPP Miami' THEN 'kippmiami'
        END = u.[db_name]
      )
    WHERE
      /* import terminated staff up to a week after termination date */
      DATEDIFF(
        DAY,
        ISNULL(
          scw.termination_date,
          CAST(CURRENT_TIMESTAMP AS DATE)
        ),
        CURRENT_TIMESTAMP
      ) <= 14
      AND (
        scw.primary_on_site_department != 'Data'
        OR scw.primary_on_site_department IS NULL
      )
    UNION ALL
    /* new users, teachernumber does not exist */
    SELECT
      scw.ps_teachernumber,
      scw.preferred_first_name,
      scw.preferred_last_name,
      scw.primary_site,
      scw.primary_site_schoolid,
      scw.primary_on_site_department,
      scw.birth_date,
      scw.termination_date,
      scw.samaccountname,
      scw.mail,
      scw.[status],
      sc.region
    FROM
      gabby.people.staff_crosswalk_static AS scw
      INNER JOIN gabby.people.school_crosswalk AS sc ON (
        scw.primary_site = sc.site_name
        AND sc._fivetran_deleted = 0
      )
      LEFT JOIN gabby.powerschool.users AS u ON (
        (
          scw.ps_teachernumber = u.teachernumber
          COLLATE LATIN1_GENERAL_BIN
        )
        AND CASE
          WHEN sc.region = 'TEAM Academy Charter School' THEN 'kippnewark'
          WHEN sc.region = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
          WHEN sc.region = 'KIPP Miami' THEN 'kippmiami'
        END = u.[db_name]
      )
    WHERE
      /* import terminated staff up to a week after termination date */
      DATEDIFF(
        DAY,
        ISNULL(
          scw.termination_date,
          CAST(CURRENT_TIMESTAMP AS DATE)
        ),
        CURRENT_TIMESTAMP
      ) <= 14
      AND (
        scw.primary_on_site_department != 'Data'
        OR scw.primary_on_site_department IS NULL
      )
      AND u.dcid IS NULL
  ),
  users_clean AS (
    /* existing users, DF schoolid matches PS homeschoolid */
    SELECT
      ps_teachernumber AS teachernumber,
      preferred_first_name AS first_name,
      preferred_last_name AS last_name,
      region AS legal_entity_name,
      primary_site_schoolid AS homeschoolid,
      CONVERT(NVARCHAR, birth_date, 101) AS dob,
      LOWER(samaccountname) AS loginid,
      LOWER(samaccountname) AS teacherloginid,
      LOWER(mail) AS email_addr,
      CASE
        WHEN DATEDIFF(
          DAY,
          ISNULL(
            termination_date,
            CAST(CURRENT_TIMESTAMP AS DATE)
          ),
          CURRENT_TIMESTAMP
        ) <= 7 THEN 1
        WHEN [status] IN (
          'ACTIVE',
          'INACTIVE',
          'PRESTART',
          'PLOA',
          'ADMIN_LEAVE'
        ) THEN 1
        WHEN termination_date >= CAST(CURRENT_TIMESTAMP AS DATE) THEN 1
        ELSE 2
      END AS [status]
    FROM
      users_union
  )
SELECT
  teachernumber,
  first_name,
  last_name,
  CASE
    WHEN [status] = 1 THEN loginid
  END AS loginid,
  CASE
    WHEN [status] = 1 THEN teacherloginid
  END AS teacherloginid,
  email_addr,
  CAST(COALESCE(homeschoolid, 0) AS INT) AS schoolid,
  CAST(COALESCE(homeschoolid, 0) AS INT) AS homeschoolid,
  [status],
  CASE
    WHEN [status] = 1 THEN 1
    ELSE 0
  END AS teacherldapenabled,
  CASE
    WHEN [status] = 1 THEN 1
    ELSE 0
  END AS adminldapenabled,
  CASE
    WHEN [status] = 1 THEN 1
    ELSE 0
  END AS ptaccess,
  /* temporarily shut off teacher gradebook access
  CASE
  WHEN df.legal_entity_name = 'KIPP TEAM and Family Schools Inc.'
  AND df.[status] = 1 THEN 1
  ELSE 0
  END AS ptaccess,
  --*/
  dob,
  legal_entity_name
FROM
  users_clean
