CREATE OR ALTER VIEW
  powerschool.course_enrollments AS
SELECT
  studentid,
  schoolid,
  termid,
  cc_id,
  course_number,
  section_number,
  dateenrolled,
  dateleft,
  lastgradeupdate,
  sectionid,
  expression,
  yearid,
  academic_year,
  student_number,
  students_dcid,
  credittype,
  course_name,
  credit_hours,
  gradescaleid,
  excludefromgpa,
  excludefromstoredgrades,
  teachernumber,
  teacher_name,
  section_enroll_status,
  map_measurementscale,
  illuminate_subject,
  abs_sectionid,
  abs_termid,
  course_enroll_status,
  sections_dcid,
  rn_subject,
  rn_course_yr,
  rn_illuminate_subject
FROM
  powerschool.course_enrollments_current_static
UNION ALL
SELECT
  studentid,
  schoolid,
  termid,
  cc_id,
  course_number,
  section_number,
  dateenrolled,
  dateleft,
  lastgradeupdate,
  sectionid,
  expression,
  yearid,
  academic_year,
  student_number,
  students_dcid,
  credittype,
  course_name,
  credit_hours,
  gradescaleid,
  excludefromgpa,
  excludefromstoredgrades,
  teachernumber,
  teacher_name,
  section_enroll_status,
  map_measurementscale,
  illuminate_subject,
  abs_sectionid,
  abs_termid,
  course_enroll_status,
  sections_dcid,
  rn_subject,
  rn_course_yr,
  rn_illuminate_subject
FROM
  powerschool.course_enrollments_archive
