CREATE OR ALTER VIEW
  extracts.razkids_teachers AS
SELECT
  google_email AS teacher_id,
  preferred_first_name AS first_name,
  preferred_last_name AS last_name,
  google_email AS email,
  primary_site AS school_organization
FROM
  gabby.people.staff_crosswalk_static
WHERE
  (
    primary_site_school_level = 'ES'
    OR primary_site = 'KIPP Hatch Middle'
  )
  AND [status] NOT IN ('TERMINATED', 'PRESTART')
