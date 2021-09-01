USE gabby
GO

CREATE OR ALTER VIEW qa.powerschool_sections_lead_terminated AS

SELECT sec.[db_name]
      ,sec.id
      ,sec.course_number
      ,sec.section_number
      ,sec.schoolid
      
      ,t.teachernumber
      
      ,scw.preferred_name
FROM gabby.powerschool.sections sec
JOIN gabby.powerschool.teachers_static t
  ON sec.teacher = t.id
 AND sec.[db_name] = t.[db_name]
JOIN gabby.people.staff_crosswalk_static scw
  ON t.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
 AND scw.[status] = 'TERMINATED'
WHERE sec.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)