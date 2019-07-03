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
 AND s.grade_level >= 2
JOIN gabby.powerschool.courses c
  ON cc.course_number = c.course_number_clean
 AND cc.db_name = c.db_name
JOIN gabby.powerschool.teachers_static t
  ON cc.teacherid = t.id
 AND cc.db_name = t.db_name
WHERE cc.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT CONCAT(co.yearid, co.schoolid, RIGHT(CONCAT(0, co.grade_level),2)) AS id
      ,CONVERT(INT,CONCAT(co.yearid, '00')) AS termid
      ,co.student_number AS studentid
      ,CONCAT(co.academic_year, s.abbreviation, co.grade_level) AS section_number
      ,co.schoolid
      ,'ENR' AS course_number
      ,'Enroll' AS course_name
      ,df.ps_teachernumber COLLATE Latin1_General_BIN AS teacher
      ,'1(A)' expression
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.schools s
  ON co.schoolid = s.school_number
 AND co.db_name = s.db_name
JOIN gabby.people.staff_crosswalk_static df
  ON co.schoolid = df.primary_site_schoolid
 AND df.primary_job = 'School Leader'
 AND df.status = 'ACTIVE'
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.grade_level BETWEEN 2 AND 12