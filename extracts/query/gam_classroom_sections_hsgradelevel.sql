WITH
  this AS (
    SELECT
      CONCAT(
        CASE
          WHEN co.[db_name] = 'kippnewark' THEN 'nwk'
          WHEN co.[db_name] = 'kippcamden' THEN 'cmd'
          WHEN co.[db_name] = 'kippmiami' THEN 'mia'
        END,
        co.schoolid,
        co.grade_level
      ) AS alias,
      co.schoolid,
      CONCAT(co.school_name, ' Grade ', co.grade_level) AS [name],
      'all' AS SECTION,
      saa.student_web_id + '@teamstudents.org' AS email
    FROM
      gabby.powerschool.cohort_identifiers_static co
      JOIN gabby.powerschool.student_access_accounts_static saa ON co.student_number = saa.student_number
    WHERE
      co.academic_year = 2019
      AND co.rn_year = 1
      AND co.enroll_status = 0
      AND co.school_level = 'HS'
  )
  -- /* Section setup
SELECT DISTINCT
  t.alias,
  t.[name],
  t.section,
  CASE
    WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(
      LEFT(
        scw.userprincipalname,
        CHARINDEX('@', scw.userprincipalname)
      )
    ) + 'kippmiami.org'
    ELSE LOWER(
      LEFT(
        scw.userprincipalname,
        CHARINDEX('@', scw.userprincipalname)
      )
    ) + 'apps.teamschools.org'
  END AS teacher
FROM
  this t
  JOIN gabby.people.staff_crosswalk_static scw ON t.schoolid = scw.primary_site_schoolid
  AND scw.primary_job = 'School Leader'
  AND scw.[status] NOT IN ('TERMINATED', 'PRESTART')
  -- */
  /*
  SELECT t.alias
  ,t.email
  FROM this t
  --*/
