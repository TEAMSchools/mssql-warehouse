USE gabby
GO

CREATE OR ALTER VIEW extracts.clever_sections AS

SELECT sec.schoolid
      ,CONCAT(
         CASE 
          WHEN sec.db_name = 'kippnewark' THEN 10
          WHEN sec.db_name = 'kippcamden' THEN 20
          WHEN sec.db_name = 'kippmiami' THEN 30
         END
        ,sec.id) AS [Section_id]
      ,t.teachernumber AS [Teacher_id]
      ,NULL AS [Teacher_2_id]
      ,NULL AS [Teacher_3_id]
      ,NULL AS [Teacher_4_id]
      ,NULL AS [Teacher_5_id]
      ,NULL AS [Teacher_6_id]
      ,NULL AS [Teacher_7_id]
      ,NULL AS [Teacher_8_id]
      ,NULL AS [Teacher_9_id]
      ,NULL AS [Teacher_10_id]
      ,NULL AS [Name]
      ,sec.section_number AS [Section_number]
      ,CASE WHEN sec.grade_level = 0 THEN 'Kindergarten' ELSE CONVERT(VARCHAR(5),sec.grade_level) END AS [Grade]      
      ,c.course_name AS [Course_name]
      ,sec.course_number_clean AS [Course_number]
      ,NULL AS [Course_description]
      ,sec.expression AS [Period]
      ,CASE
        WHEN c.credittype = 'ART' THEN 'Arts and music'
        WHEN c.credittype = 'CAREER' THEN 'other'
        WHEN c.credittype = 'COCUR' THEN 'other'
        WHEN c.credittype = 'ELEC' THEN 'other'
        WHEN c.credittype = 'ENG' THEN 'English/language arts'
        WHEN c.credittype = 'LOG' THEN 'other'
        WHEN c.credittype = 'MATH' THEN 'Math'
        WHEN c.credittype = 'NULL' THEN 'Homeroom/advisory'
        WHEN c.credittype = 'PHYSED' THEN 'PE and health'
        WHEN c.credittype = 'RHET' THEN 'English/language arts'
        WHEN c.credittype = 'SCI' THEN 'Science'
        WHEN c.credittype = 'SOC' THEN 'Social studies'
        WHEN c.credittype = 'STUDY' THEN 'other'
        WHEN c.credittype = 'WLANG' THEN 'Language'
       END AS [Subject]
      ,terms.abbreviation [Term_name]
      ,CONVERT(VARCHAR(25), terms.firstday, 101) AS [Term_start]
      ,CONVERT(VARCHAR(25), terms.lastday, 101) AS [Term_end]
FROM gabby.powerschool.sections sec
JOIN gabby.powerschool.teachers_static t
  ON sec.teacher = t.id
 AND sec.db_name = t.db_name
JOIN gabby.powerschool.courses c
  ON sec.course_number_clean = c.course_number_clean
 AND sec.db_name = c.db_name
JOIN gabby.powerschool.terms
  ON sec.termid = terms.id
 AND sec.schoolid = terms.schoolid
 AND sec.db_name = terms.db_name
WHERE LEFT(sec.termid, 2) + 1990 = gabby.utilities.GLOBAL_ACADEMIC_YEAR()