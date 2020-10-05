USE gabby
GO

CREATE OR ALTER VIEW extracts.littlesis_enrollments AS

SELECT enr.schoolid AS school_id
      ,enr.course_number AS course_id
      ,enr.sectionid AS section_id
      ,enr.termid AS term_id
      ,enr.section_number
      ,enr.student_number AS student_id

      ,sec.external_expression AS [period]
      ,sec.room

      ,sch.[name] AS school_name
      
      ,saa.student_web_id + '@teamstudents.org' AS student_gsuite_email

      ,CONCAT(
          enr.course_name
         ,' (' + enr.course_number + ') - '
         ,enr.section_number + ' - '
         ,gabby.utilities.GLOBAL_ACADEMIC_YEAR(), '-'
         ,RIGHT(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 2) + 1
        ) AS class_name

      ,CASE
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
        ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
       END AS teacher_gsuite_email
FROM gabby.powerschool.course_enrollments_static enr
JOIN gabby.powerschool.sections sec
  ON enr.sectionid = sec.id
 AND enr.[db_name] = sec.[db_name]
JOIN gabby.powerschool.schools sch
  ON enr.schoolid = sch.school_number
 AND enr.[db_name] = sch.[db_name]
JOIN gabby.powerschool.student_access_accounts_static saa
  ON enr.student_number = saa.student_number
LEFT JOIN gabby.people.staff_crosswalk_static scw
  ON enr.teachernumber = scw.ps_teachernumber COLLATE LATIN1_GENERAL_BIN
WHERE enr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND enr.course_enroll_status = 0
  AND enr.section_enroll_status = 0
  AND enr.credittype <> 'LOG'
