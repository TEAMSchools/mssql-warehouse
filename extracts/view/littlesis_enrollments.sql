CREATE OR ALTER VIEW
  extracts.littlesis_enrollments AS
SELECT
  sec.schoolid AS school_id,
  sec.course_number AS course_id,
  sec.sectionid AS section_id,
  sec.termid AS term_id,
  sec.section_number,
  QUOTENAME(sec.[period], '"') AS [period],
  sec.room,
  sec.school_name,
  sec.class_name,
  sec.teacher_gsuite_email,
  stu.student_number AS student_id,
  stu.student_gsuite_email
FROM
  gabby.extracts.gclassroom_sections AS sec
  LEFT JOIN gabby.extracts.gclassroom_students AS stu ON sec.class_alias = stu.class_alias /* trunk-ignore(sqlfluff/L016) */
