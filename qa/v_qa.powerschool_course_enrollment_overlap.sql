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
      ,cc.sectionid
      ,cc.dateenrolled
      ,cc.dateleft
      ,cc.[db_name]
FROM gabby.powerschool.cc
INNER JOIN gabby.powerschool.students s
  ON cc.studentid = s.id
INNER JOIN gabby.powerschool.sections_identifiers sec
  ON ABS(cc.sectionid) = sec.sectionid
 AND cc.[db_name] = sec.[db_name]
WHERE CONCAT(cc.studentid, cc.studyear, cc.course_number, cc.[db_name]) IN (SELECT CONCAT(studentid, studyear, course_number, [db_name]) COLLATE Latin1_General_BIN FROM cc_lag WHERE dateleft <= dateleft_prev)
