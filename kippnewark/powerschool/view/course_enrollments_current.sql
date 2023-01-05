CREATE OR ALTER VIEW
  powerschool.course_enrollments_current AS
SELECT
  studentid,
  schoolid,
  termid,
  cc_id,
  course_number,
  section_number,
  dateenrolled,
  dateleft,
  NULL AS lastgradeupdate,
  sectionid,
  expression,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990 AS yearid,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year,
  student_number,
  students_dcid,
  credittype,
  course_name,
  credit_hours,
  courses_gradescaleid AS gradescaleid,
  excludefromgpa,
  excludefromstoredgrades,
  teachernumber,
  teacher_lastfirst AS teacher_name,
  section_enroll_status,
  map_measurementscale,
  illuminate_subject,
  abs_sectionid,
  abs_termid,
  course_enroll_status,
  sections_dcid,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      credittype
    ORDER BY
      termid DESC,
      dateenrolled DESC,
      dateleft DESC
  ) AS rn_subject,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      course_number
    ORDER BY
      termid DESC,
      dateenrolled DESC,
      dateleft DESC
  ) AS rn_course_yr,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      illuminate_subject
    ORDER BY
      termid DESC,
      dateenrolled DESC,
      dateleft DESC
  ) AS rn_illuminate_subject
FROM
  (
    SELECT
      studentid,
      schoolid,
      termid,
      cc_id,
      course_number,
      section_number,
      dateenrolled,
      dateleft,
      sectionid,
      expression,
      student_number,
      students_dcid,
      credittype,
      course_name,
      credit_hours,
      excludefromgpa,
      excludefromstoredgrades,
      teachernumber,
      teacher_lastfirst,
      section_enroll_status,
      map_measurementscale,
      illuminate_subject,
      abs_sectionid,
      abs_termid,
      sections_dcid,
      courses_gradescaleid,
      SUM(section_enroll_status) OVER (
        PARTITION BY
          studentid,
          course_number
      ) / COUNT(sectionid) OVER (
        PARTITION BY
          studentid,
          course_number
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
            WHEN (
              cc.sectionid < 0
              AND s.enroll_status = 2
              AND s.exitdate = cc.dateleft
            ) THEN 0
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
          CAST(
            sj.illuminate_subject AS VARCHAR(125)
          ) AS illuminate_subject
        FROM
          powerschool.cc
          INNER JOIN powerschool.students AS s ON (cc.studentid = s.id)
          INNER JOIN powerschool.sections_identifiers AS sec ON (
            ABS(cc.sectionid) = sec.sectionid
          )
          LEFT JOIN gabby.assessments.normed_subjects AS sj ON (
            cc.course_number = sj.course_number
            COLLATE SQL_Latin1_General_CP1_CI_AS
          )
        WHERE
          cc.dateenrolled >= DATEFROMPARTS(
            gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
            7,
            1
          )
      ) AS sub
  ) AS sub
