USE gabby;
GO

CREATE OR ALTER VIEW extracts.illuminate_mastschd AS

SELECT CONCAT(CASE
               WHEN enr.db_name = 'kippnewark' THEN 10
               WHEN enr.db_name = 'kippcamden' THEN 20
               WHEN enr.db_name = 'kippmiami' THEN 30
              END
             ,enr.sectionid) AS [01 Section ID]
      ,enr.schoolid AS [02 Site ID]
      ,t.name AS [03 Term Name]
      ,enr.course_number AS [04 Course ID]
      ,enr.teachernumber AS [05 User ID]
      ,enr.expression AS [06 Period]
      ,CONCAT(academic_year, '-', (academic_year + 1)) AS [07 Academic Year]
      ,NULL AS [08 Room Number]
      ,NULL AS [09 Session Type ID]
      ,NULL AS [10 Local Term ID]
      ,NULL AS [11 Quarter Num]
      ,enr.dateenrolled AS [12 User Start Date]
      ,enr.dateleft AS [13 User End Date]
      ,1 AS [14 Primary Teacher]
      ,NULL AS [15 Teacher Competency Level]
      ,NULL AS [16 Is Attendance Enabled]
FROM gabby.powerschool.course_enrollments_static enr
JOIN gabby.powerschool.terms t
  ON enr.termid = t.id
 AND enr.schoolid = t.schoolid
 AND enr.db_name = t.db_name
WHERE enr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR();