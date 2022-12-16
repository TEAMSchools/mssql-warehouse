USE gabby GO
CREATE OR ALTER VIEW
  extracts.gclassroom_teachers AS
SELECT
  s.class_alias,
  s.schoolid,
  s.termid,
  s.[db_name],
  scw.df_employee_number,
  scw.preferred_name,
  scw.google_email AS teacher_gsuite_email
FROM
  gabby.extracts.gclassroom_sections AS s
  INNER JOIN gabby.powerschool.sectionteacher AS st ON s.sectionid = st.sectionid
  AND s.[db_name] = st.[db_name]
  INNER JOIN gabby.powerschool.roledef AS r ON st.roleid = r.id
  AND st.[db_name] = r.[db_name]
  AND r.[name] != 'Lead Teacher'
  INNER JOIN gabby.powerschool.teachers_static AS t ON st.teacherid = t.id
  AND s.schoolid = t.schoolid
  AND st.[db_name] = t.[db_name]
  INNER JOIN gabby.people.staff_crosswalk_static AS scw ON t.teachernumber = scw.ps_teachernumber
COLLATE Latin1_General_BIN
