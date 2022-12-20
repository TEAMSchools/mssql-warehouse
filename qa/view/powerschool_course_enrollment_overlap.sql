CREATE OR ALTER VIEW
  qa.powerschool_course_enrollment_overlap AS
WITH
  cc_lag AS (
    SELECT
      studentid,
      studyear,
      schoolid,
      course_number,
      sectionid,
      dateenrolled,
      dateleft,
      [db_name],
      LAG(dateleft) OVER (
        PARTITION BY
          studentid,
          studyear,
          course_number,
          [db_name]
        ORDER BY
          dateleft
      ) AS dateleft_prev
    FROM
      gabby.powerschool.cc
  )
SELECT
  cc.studentid,
  cc.schoolid,
  cc.course_number,
  cc.sectionid,
  cc.section_number,
  cc.dateenrolled,
  cc.dateleft,
  cc.[db_name],
  CAST(RIGHT(cc.studyear, 2) AS INT) + 1990 AS academic_year,
  s.student_number,
  s.lastfirst,
  s.grade_level,
  s.team,
  sec.course_name
FROM
  gabby.powerschool.cc
  INNER JOIN gabby.powerschool.students AS s ON cc.studentid = s.id
  AND cc.[db_name] = s.[db_name]
  INNER JOIN gabby.powerschool.sections_identifiers AS sec ON ABS(cc.sectionid) = sec.sectionid
  AND cc.[db_name] = sec.[db_name]
WHERE
  CONCAT(
    cc.studentid,
    cc.studyear,
    cc.course_number,
    cc.[db_name]
  ) IN (
    SELECT
      (
        CONCAT(
          studentid,
          studyear,
          course_number,
          [db_name]
        )
        COLLATE LATIN1_GENERAL_BIN
      )
    FROM
      cc_lag
    WHERE
      dateleft <= dateleft_prev
  )
