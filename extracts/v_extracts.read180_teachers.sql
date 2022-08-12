USE gabby
GO

CREATE OR ALTER VIEW extracts.read180_teachers AS

SELECT scw.df_employee_number AS DISTRICT_USER_ID
      ,NULL AS SPS_ID
      ,NULL AS PREFIX
      ,scw.preferred_first_name AS FIRST_NAME
      ,scw.preferred_last_name AS LAST_NAME
      ,NULL AS TITLE
      ,NULL AS SUFFIX
      ,scw.mail AS EMAIL
      ,scw.samaccountname AS [USER_NAME]
      ,NULL AS [PASSWORD]
      ,sch.[name] AS SCHOOL_NAME
      ,CONCAT(sec.course_number, '.', UPPER(sec.section_number)) AS CLASS_NAME
      ,scw.google_email AS EXTERNAL_ID
FROM gabby.powerschool.sections sec
JOIN gabby.powerschool.sectionteacher st
  ON sec.id = st.sectionid
 AND sec.[db_name] = st.[db_name]
JOIN gabby.powerschool.teachers_static t
  ON st.teacherid = t.id
 AND st.[db_name] = t.[db_name]
JOIN gabby.people.staff_crosswalk_static scw
  ON t.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
JOIN gabby.powerschool.schools sch
  ON sec.schoolid = sch.school_number
 AND sec.[db_name] = sch.[db_name]
WHERE sec.termid >= ((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990) * 100)
  AND sec.course_number IN ('ELA01068G1', 'MAT02999G1')
