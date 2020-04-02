USE gabby
GO

CREATE OR ALTER VIEW extracts.clever_enrollments AS

SELECT cc.schoolid AS [School_id]
      ,CONCAT(CASE 
               WHEN cc.[db_name] = 'kippnewark' THEN 'NWK'
               WHEN cc.[db_name] = 'kippcamden' THEN 'CMD'
               WHEN cc.[db_name] = 'kippmiami' THEN 'MIA'
              END
             ,cc.sectionid) AS [Section_id]
      ,s.student_number AS [Student_id]
FROM gabby.powerschool.cc
JOIN gabby.powerschool.students s
  ON cc.studentid = s.id
 AND cc.[db_name] = s.[db_name]
WHERE cc.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

/* ENR sections */
SELECT schoolid AS [School_id]
      ,CONCAT(yearid, schoolid, RIGHT(CONCAT(0, grade_level), 2)) AS [Section_id]
      ,student_number AS [Student_id]
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND rn_year = 1
  AND grade_level != 99

UNION ALL

/* demo students */
SELECT cc.schoolid AS [School_id]
      ,CONCAT(CASE 
               WHEN cc.[db_name] = 'kippnewark' THEN 'NWK'
               WHEN cc.[db_name] = 'kippcamden' THEN 'CMD'
               WHEN cc.[db_name] = 'kippmiami' THEN 'MIA'
              END
             ,cc.sectionid) AS [Section_id]
      ,CONCAT(999, s.student_number) AS [Student_id]
FROM gabby.powerschool.cc
JOIN gabby.powerschool.students s
  ON cc.studentid = s.id
 AND cc.[db_name] = s.[db_name]
 AND s.student_number IN (17453, 11900)
WHERE cc.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()