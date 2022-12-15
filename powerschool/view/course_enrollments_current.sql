CREATE OR ALTER VIEW
  powerschool.course_enrollments_current AS
SELECT
  sub.studentid,
  sub.schoolid,
  sub.termid,
  sub.cc_id,
  sub.course_number,
  sub.section_number,
  sub.dateenrolled,
  sub.dateleft,
  NULL AS lastgradeupdate,
  sub.sectionid,
  sub.expression,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990 AS yearid,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year,
  sub.student_number,
  sub.students_dcid,
  sub.credittype,
  sub.course_name,
  sub.credit_hours,
  sub.courses_gradescaleid AS gradescaleid,
  sub.excludefromgpa,
  sub.excludefromstoredgrades,
  sub.teachernumber,
  sub.teacher_lastfirst AS teacher_name,
  sub.section_enroll_status,
  sub.map_measurementscale,
  sub.illuminate_subject,
  sub.abs_sectionid,
  sub.abs_termid,
  sub.course_enroll_status,
  sub.sections_dcid,
  ROW_NUMBER() OVER (
    PARTITION BY
      sub.student_number,
      sub.credittype
    ORDER BY
      sub.termid DESC,
      sub.dateenrolled DESC,
      sub.dateleft DESC
  ) AS rn_subject,
  ROW_NUMBER() OVER (
    PARTITION BY
      sub.student_number,
      sub.course_number
    ORDER BY
      sub.termid DESC,
      sub.dateenrolled DESC,
      sub.dateleft DESC
  ) AS rn_course_yr,
  ROW_NUMBER() OVER (
    PARTITION BY
      sub.student_number,
      sub.illuminate_subject
    ORDER BY
      sub.termid DESC,
      sub.dateenrolled DESC,
      sub.dateleft DESC
  ) AS rn_illuminate_subject
FROM
  (
    SELECT
      sub.studentid,
      sub.schoolid,
      sub.termid,
      sub.cc_id,
      sub.course_number,
      sub.section_number,
      sub.dateenrolled,
      sub.dateleft,
      sub.sectionid,
      sub.expression,
      sub.student_number,
      sub.students_dcid,
      sub.credittype,
      sub.course_name,
      sub.credit_hours,
      sub.excludefromgpa,
      sub.excludefromstoredgrades,
      sub.teachernumber,
      sub.teacher_lastfirst,
      sub.section_enroll_status,
      sub.map_measurementscale,
      sub.illuminate_subject,
      sub.abs_sectionid,
      sub.abs_termid,
      sub.sections_dcid,
      sub.courses_gradescaleid,
      SUM(sub.section_enroll_status) OVER (
        PARTITION BY
          sub.studentid,
          sub.course_number
      ) / COUNT(sub.sectionid) OVER (
        PARTITION BY
          sub.studentid,
          sub.course_number
      ) AS course_enroll_status
    FROM
      (
        SELECT
          cc.studentid,
          cc.schoolid,
          cc.termid,
          cc.id AS cc_id,
          cc.course_number,
          cc.section_number,
          cc.dateenrolled,
          cc.dateleft,
          cc.sectionid,
          cc.expression,
          ABS(cc.termid) AS abs_termid,
          ABS(cc.sectionid) AS abs_sectionid,
          CASE
            WHEN cc.sectionid < 0
            AND s.enroll_status = 2
            AND s.exitdate = cc.dateleft THEN 0
            WHEN cc.sectionid < 0 THEN 1
            ELSE 0
          END AS section_enroll_status,
          s.student_number,
          s.dcid AS students_dcid,
          sec.dcid AS sections_dcid,
          sec.credittype,
          sec.course_name,
          sec.credit_hours,
          sec.excludefromgpa,
          sec.excludefromstoredgrades,
          sec.courses_gradescaleid,
          sec.teachernumber,
          sec.teacher_lastfirst,
          CASE
            WHEN sec.credittype IN ('ENG', 'READ') THEN 'Reading'
            WHEN sec.credittype = 'MATH' THEN 'Mathematics'
            WHEN sec.credittype = 'RHET' THEN 'Language Usage'
            WHEN sec.credittype = 'SCI' THEN 'Science - General Science'
          END AS map_measurementscale,
          CAST(sj.illuminate_subject AS VARCHAR(125)) AS illuminate_subject
        FROM
          powerschool.cc
          INNER JOIN powerschool.students AS s ON cc.studentid = s.id
          INNER JOIN powerschool.sections_identifiers AS sec ON ABS(cc.sectionid) = sec.sectionid
          LEFT JOIN gabby.assessments.normed_subjects AS sj ON cc.course_number = sj.course_number
        COLLATE Latin1_General_BIN
        WHERE
          cc.dateenrolled >= DATEFROMPARTS(
            gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
            7,
            1
          )
      ) sub
  ) sub
