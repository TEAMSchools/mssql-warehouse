USE gabby;
GO

CREATE OR ALTER VIEW extracts.illuminate_mastschd AS

SELECT CONCAT(CASE
               WHEN sec.db_name = 'kippnewark' THEN 'NWK'
               WHEN sec.db_name = 'kippcamden' THEN 'CMD'
               WHEN sec.db_name = 'kippmiami' THEN 'MIA'
              END
             ,sec.id) AS [01 Section ID]
      ,sec.schoolid AS [02 Site ID]
      ,tr.name AS [03 Term Name]
      ,sec.course_number AS [04 Course ID]
      ,t.teachernumber AS [05 User ID]
      ,CASE WHEN sec.schoolid = 73253 THEN sec.expression ELSE sec.section_number END AS [06 Period]
      ,CONCAT((sec.yearid + 1990), '-', (sec.yearid + 1991)) AS [07 Academic Year]
      ,NULL AS [08 Room Number]
      ,NULL AS [09 Session Type ID]
      ,NULL AS [10 Local Term ID]
      ,NULL AS [11 Quarter Num]
      ,tr.firstday AS [12 User Start Date]
      ,tr.lastday AS [13 User End Date]
      ,1 AS [14 Primary Teacher]
      ,NULL AS [15 Teacher Competency Level]
      ,NULL AS [16 Is Attendance Enabled]
FROM gabby.powerschool.sections sec
JOIN gabby.powerschool.terms tr
  ON sec.termid = tr.id
 AND sec.schoolid = tr.schoolid
 AND sec.db_name = tr.db_name
JOIN gabby.powerschool.teachers_static t
  ON sec.teacher = t.id
 AND sec.db_name = t.db_name
WHERE sec.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990);