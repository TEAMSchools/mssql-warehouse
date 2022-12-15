USE gabby GO
CREATE OR ALTER VIEW
  extracts.razkids_students AS
SELECT
  saa.student_web_id + '@teamstudents.org' AS student_id,
  scw.google_email AS teacher_id,
  s.first_name,
  s.last_name,
  NULL AS reading_level,
  NULL AS [password],
  CASE
    WHEN s.grade_level = 0 THEN 'KG'
    ELSE RIGHT(CONCAT('0', s.grade_level), 2)
  END AS grade
FROM
  gabby.powerschool.course_enrollments_current_static AS enr
  INNER JOIN gabby.powerschool.student_access_accounts_static AS saa ON enr.student_number = saa.student_number
  INNER JOIN gabby.powerschool.students AS s ON enr.student_number = s.student_number
  AND enr.[db_name] = s.[db_name]
  AND s.enroll_status = 0
  AND s.grade_level <= 4
  INNER JOIN gabby.people.staff_crosswalk_static AS scw ON enr.teachernumber = scw.ps_teachernumber
COLLATE Latin1_General_BIN
WHERE
  enr.course_number = 'HR'
  AND enr.course_enroll_status = 0
  AND enr.section_enroll_status = 0
  AND enr.rn_course_yr = 1
