WITH
  slap AS (
    SELECT
      scw.primary_site_schoolid,
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
      END AS gsuite_email
    FROM
      gabby.people.staff_crosswalk_static scw
    WHERE
      scw.[status] NOT IN ('TERMINATED', 'PRESTART')
      AND scw.primary_job IN ('School Leader', 'Assistant School Leader')
  )
SELECT DISTINCT
  CONCAT(
    CASE
      WHEN s.[db_name] = 'kippnewark' THEN 'nwk'
      WHEN s.[db_name] = 'kippcamden' THEN 'cmd'
      WHEN s.[db_name] = 'kippmiami' THEN 'mia'
    END,
    s.teacher,
    s.course_number_clean
  ) AS alias,
  sl.gsuite_email AS teacher
FROM
  gabby.powerschool.sections s
  INNER JOIN gabby.powerschool.courses c ON s.course_number_clean = c.course_number_clean
  AND s.[db_name] = c.[db_name]
  AND c.credittype <> 'LOG'
  INNER JOIN slap sl ON s.schoolid = sl.primary_site_schoolid
WHERE
  s.yearid = (gabby.utilities.global_academic_year () - 1990)
ORDER BY
  sl.gsuite_email,
  alias
