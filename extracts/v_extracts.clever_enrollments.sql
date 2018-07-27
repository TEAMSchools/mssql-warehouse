USE gabby
GO

CREATE OR ALTER VIEW extracts.clever_enrollments AS

SELECT cc.schoolid AS [School_id]
      ,CONCAT(
         CASE 
          WHEN cc.db_name = 'kippnewark' THEN 10
          WHEN cc.db_name = 'kippcamden' THEN 20
          WHEN cc.db_name = 'kippmiami' THEN 30
         END
        ,cc.sectionid) AS [Section_id]
      ,s.student_number AS [Student_id]
FROM gabby.powerschool.cc
JOIN gabby.powerschool.students s
  ON cc.studentid = s.id
 AND cc.db_name = s.db_name
WHERE cc.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()