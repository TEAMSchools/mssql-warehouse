USE gabby
GO

CREATE OR ALTER VIEW qa.powerschool_course_enrollment_overlap AS

WITH cc_lag AS (
  SELECT studentid
        ,studyear
        ,schoolid
        ,course_number
        ,sectionid
        ,dateenrolled
        ,dateleft
        ,[db_name]
        ,LAG(dateleft) OVER(PARTITION BY studentid, studyear, course_number, [db_name] ORDER BY dateleft) AS dateleft_prev
  FROM gabby.powerschool.cc
)

SELECT cc.studentid
      ,s.student_number
      ,CAST(RIGHT(cc.studyear, 2) AS INT) + 1990 AS academic_year
      ,cc.schoolid
      ,cc.course_number
      ,sec.course_name
      ,sec.sectionid
      ,cc.dateenrolled
      ,cc.dateleft
      ,cc.dateleft_prev
      ,cc.[db_name]
FROM cc_lag cc
INNER JOIN gabby.powerschool.students s
  ON cc.studentid = s.id
INNER JOIN gabby.powerschool.sections_identifiers sec
  ON ABS(cc.sectionid) = sec.sectionid
 AND cc.[db_name] = sec.[db_name]
WHERE cc.dateleft <= cc.dateleft_prev
  AND cc.dateenrolled >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
