CREATE OR ALTER VIEW
  extracts.gclassroom_students AS
SELECT
  sec.class_alias,
  sec.schoolid,
  sec.termid,
  sec.[db_name],
  sec.section_number,
  s.student_number,
  sas.student_web_id + '@teamstudents.org' AS student_gsuite_email
FROM
  gabby.extracts.gclassroom_sections AS sec
  INNER JOIN gabby.powerschool.cc ON sec.sectionid = cc.sectionid
  AND sec.[db_name] = cc.[db_name]
  AND cc.sectionid > 0
  INNER JOIN gabby.powerschool.students AS s ON cc.studentid = s.id
  AND cc.[db_name] = s.[db_name]
  AND s.enroll_status = 0
  INNER JOIN gabby.powerschool.student_access_accounts_static AS sas ON s.student_number = sas.student_number
