USE gabby GO
CREATE OR ALTER VIEW
  extracts.razkids_teachers AS
SELECT
  scw.google_email AS teacher_id,
  scw.preferred_first_name AS first_name,
  scw.preferred_last_name AS last_name,
  scw.google_email AS email,
  scw.primary_site AS school_organization
FROM
  gabby.people.staff_crosswalk_static scw
WHERE
  (
    scw.primary_site_school_level = 'ES'
    OR scw.primary_site = 'KIPP Hatch Middle'
  )
  AND scw.[status] NOT IN ('TERMINATED', 'PRESTART')
