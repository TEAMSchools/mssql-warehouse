USE gabby
GO

CREATE OR ALTER VIEW extracts.razkids_students AS

SELECT saa.student_web_id + '@teamstudents.org' AS student_id
      ,CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS teacher_id
      ,s.first_name
      ,s.last_name
      ,NULL AS reading_level
      ,NULL AS [password]
      ,CASE
        WHEN s.grade_level = 0 THEN 'KG'
        ELSE RIGHT(CONCAT('0', s.grade_level), 2)
       END AS grade
FROM gabby.powerschool.course_enrollments_static enr
JOIN gabby.powerschool.student_access_accounts_static saa
  ON enr.student_number = saa.student_number
JOIN gabby.powerschool.students s
  ON enr.student_number = s.student_number
 AND enr.[db_name] = s.[db_name]
 AND s.enroll_status = 0
 AND s.grade_level <= 4
JOIN gabby.people.staff_crosswalk_static scw
  ON enr.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
WHERE enr.course_number = 'HR'
  AND enr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND enr.course_enroll_status = 0
  AND enr.section_enroll_status = 0
  AND enr.rn_course_yr = 1
