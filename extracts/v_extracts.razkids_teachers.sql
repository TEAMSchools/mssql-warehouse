USE gabby
GO

CREATE OR ALTER VIEW extracts.razkids_teachers AS

SELECT CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS teacher_id
      ,scw.preferred_first_name AS first_name
      ,scw.preferred_last_name AS last_name
      ,CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS email
      ,scw.primary_site AS school_organization
FROM gabby.people.staff_crosswalk_static scw
WHERE (scw.primary_site_school_level = 'ES' OR scw.primary_site = 'KIPP Whittier Middle')
  AND scw.[status] NOT IN ('TERMINATED', 'PRESTART')
