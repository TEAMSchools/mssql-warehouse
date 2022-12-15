USE gabby
GO

CREATE OR ALTER VIEW extracts.fpodms_students AS

SELECT co.student_number AS [studentIdentifier]
      ,co.first_name AS [firstName]
      ,co.last_name AS [lastName]
      ,co.grade_level + 1 AS [gradeId]
      ,CONVERT(VARCHAR, CAST(co.entrydate AS DATETIME2), 126) AS [classStudentStartDate]
      ,CONVERT(VARCHAR, CAST(co.exitdate AS DATETIME2), 126) AS [classStudentEndDate]

      ,sch.[name] AS [schoolName]
FROM gabby.powerschool.cohort_identifiers_static co
INNER JOIN gabby.powerschool.schools sch
  ON co.schoolid = sch.school_number
 AND co.[db_name] = sch.[db_name]
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.is_enrolled_recent = 1
  AND co.rn_year = 1
  AND co.grade_level <= 4
