CREATE OR ALTER VIEW powerschool.sections_identifiers AS

SELECT sec.dcid
      ,sec.id AS sectionid
      ,sec.section_number
      ,sec.section_type
      ,sec.termid
      ,sec.course_number
      ,sec.schoolid
      ,sec.teacher
      ,sec.grade_level
      ,sec.expression
      ,sec.external_expression
      ,sec.room
      ,sec.gradescaleid AS sections_gradescaleid

      ,cou.course_name
      ,cou.credittype
      ,cou.credit_hours
      ,cou.excludefromgpa
      ,cou.excludefromstoredgrades
      ,cou.gradescaleid AS courses_gradescaleid

      ,t.teachernumber
      ,t.lastfirst AS teacher_lastfirst
FROM powerschool.sections sec
INNER JOIN powerschool.courses cou
  ON sec.course_number = cou.course_number
INNER JOIN powerschool.teachers_static t
  ON sec.teacher = t.id
 AND sec.schoolid = t.schoolid
