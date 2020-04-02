WITH hr_teachers AS (
  SELECT t.teachernumber COLLATE Latin1_General_BIN AS teachernumber
        ,t.[db_name]
  FROM gabby.powerschool.sections sec
  JOIN gabby.powerschool.teachers_static t
    ON sec.teacher = t.id
   AND sec.schoolid = t.schoolid
   AND sec.[db_name] = t.[db_name]
  WHERE sec.course_number_clean = 'HR'
    AND sec.yearid = 29
    AND sec.no_of_students > 0
 )

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
      
      ,CASE 
        WHEN hr.teachernumber IS NOT NULL THEN 'teacher'
        ELSE 'school_admin'
       END AS [role]
FROM gabby.people.staff_crosswalk_static scw
LEFT JOIN hr_teachers hr
  ON scw.ps_teachernumber = hr.teachernumber
 AND scw.[db_name] = hr.[db_name]
WHERE scw.primary_site_school_level = 'ES'
  AND scw.[status] NOT IN ('TERMINATED', 'PRESTART')
ORDER BY hr.teachernumber