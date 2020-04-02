SELECT DISTINCT 
       CONCAT(CASE
               WHEN s.[db_name] = 'kippnewark' THEN 'nwk'
               WHEN s.[db_name] = 'kippcamden' THEN 'cmd'
               WHEN s.[db_name] = 'kippmiami' THEN 'mia'
              END
             ,s.teacher
             ,s.course_number_clean) AS alias

      ,CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS teacher
FROM gabby.powerschool.sections s
JOIN gabby.powerschool.courses c
  ON s.course_number_clean = c.course_number_clean
 AND s.[db_name] = c.[db_name] 
 AND c.credittype != 'LOG'
JOIN gabby.powerschool.sectionteacher st
  ON s.id = st.sectionid
 AND s.[db_name] = st.[db_name]
 AND st.roleid IN (25, 26, 41, 42)
JOIN gabby.powerschool.teachers_static t
  ON st.teacherid = t.id
 AND s.schoolid = t.schoolid
 AND st.[db_name] = t.[db_name]
JOIN gabby.people.staff_crosswalk_static scw
  ON t.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
WHERE s.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)
  AND s.teacher != st.teacherid