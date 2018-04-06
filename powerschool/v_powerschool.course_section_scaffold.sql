USE gabby
GO

CREATE OR ALTER VIEW powerschool.course_section_scaffold AS 

SELECT studentid
      ,student_number
      ,yearid
      ,term_name
      ,is_curterm
      ,course_number
      ,excludefromgpa
      ,sectionid
FROM gabby.powerschool.course_section_scaffold_current_static

UNION ALL

SELECT studentid
      ,student_number
      ,yearid
      ,term_name
      ,is_curterm
      ,course_number
      ,excludefromgpa
      ,sectionid
FROM gabby.powerschool.course_section_scaffold_archive