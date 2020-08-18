USE gabby
GO

CREATE OR ALTER VIEW extracts.gclassroom_teachers AS

SELECT s.class_alias
      ,s.schoolid
      ,s.termid

      ,CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS teacher_gsuite_email
FROM gabby.extracts.gclassroom_sections s
JOIN gabby.powerschool.sectionteacher st
  ON s.sectionid = st.sectionid
 AND s.[db_name] = st.[db_name]
JOIN gabby.powerschool.roledef r
  ON st.roleid = r.id
 AND st.[db_name] = r.[db_name]
 AND r.[name] <> 'Lead Teacher'
JOIN gabby.powerschool.teachers_static t
  ON st.teacherid = t.id
 AND s.schoolid = t.schoolid
 AND st.[db_name] = t.[db_name]
JOIN gabby.people.staff_crosswalk_static scw
  ON t.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
