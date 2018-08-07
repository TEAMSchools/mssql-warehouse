USE gabby;
GO

CREATE OR ALTER VIEW extracts.renlearn_student_schedules AS

SELECT cc.id
      ,cc.termid
      ,s.student_number AS studentid
      ,cc.section_number
      ,cc.schoolid
      ,cc.course_number
      ,c.course_name
      ,t.teachernumber AS teacher
      ,cc.expression
FROM gabby.powerschool.cc
JOIN gabby.powerschool.students s
  ON cc.studentid = s.id
 AND cc.db_name = s.db_name
JOIN gabby.powerschool.courses c
  ON cc.course_number = c.course_number
 AND cc.db_name = c.db_name
JOIN gabby.powerschool.teachers_static t
  ON cc.teacherid = t.id
 AND cc.db_name = t.db_name
WHERE cc.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND cc.db_name != 'kippmiami'

UNION ALL

SELECT CONCAT(co.yearid, co.schoolid, RIGHT(CONCAT(0, co.grade_level),2)) AS id
      ,CONVERT(INT,CONCAT(co.yearid, '00')) AS termid
      ,co.student_number AS studentid
      ,CONCAT(co.academic_year, s.abbreviation, co.grade_level) AS section_number
      ,co.schoolid
      ,'ENR' AS course_number
      ,'Enroll' AS course_name
      ,COALESCE(ps.ps_teachernumber, CONVERT(VARCHAR(25),df.df_employee_number)) COLLATE Latin1_General_BIN AS teacher
      ,'1(A)' expression
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.schools s
  ON co.schoolid = s.school_number
 AND co.db_name = s.db_name
JOIN gabby.dayforce.staff_roster df
  ON co.schoolid = df.primary_site_schoolid
 AND df.primary_job = 'School Leader'
 AND df.status = 'ACTIVE'
 AND df.legal_entity_name != 'KIPP New Jersey'
LEFT JOIN gabby.people.id_crosswalk_powerschool ps
  ON df.df_employee_number = ps.df_employee_number
 AND ps.is_master = 1
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.schoolid != 999999
  AND co.db_name != 'kippmiami'