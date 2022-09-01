USE gabby;
GO

CREATE OR ALTER VIEW extracts.renlearn_student_schedules AS

WITH dsos AS (
  SELECT df.ps_teachernumber COLLATE Latin1_General_BIN AS teacher
        ,COALESCE(ccw.ps_school_id, df.primary_site_schoolid) AS schoolid
  FROM gabby.people.staff_crosswalk_static df
  LEFT JOIN gabby.people.campus_crosswalk ccw
    ON df.primary_site = ccw.campus_name
   AND ccw._fivetran_deleted = 0
   AND ccw.is_pathways = 0
  WHERE df.[status] <> 'TERMINATED'
    AND df.primary_job IN ('Director of Campus Operations', 'Director Campus Operations', 'Director School Operations')
 )

SELECT CAST(enr.cc_id AS BIGINT) AS id
      ,enr.termid
      ,enr.student_number AS studentid
      ,enr.section_number
      ,enr.schoolid
      ,enr.course_number
      ,enr.course_name
      ,enr.teachernumber AS teacher
      ,enr.expression
FROM gabby.powerschool.course_enrollments_current_static enr
JOIN gabby.powerschool.schools sch
  ON enr.schoolid = sch.school_number
 AND enr.[db_name] = sch.[db_name]
WHERE enr.course_enroll_status = 0
  AND enr.section_enroll_status = 0

UNION ALL

SELECT CONCAT(co.yearid, co.schoolid, RIGHT(CONCAT(0, co.grade_level), 2)) AS id
      ,CAST(CONCAT(co.yearid, '00') AS INT) AS termid
      ,co.student_number AS studentid
      ,CONCAT(co.academic_year, s.abbreviation, co.grade_level) AS section_number
      ,co.schoolid
      ,'ENR' AS course_number
      ,'Enroll' AS course_name
      ,dsos.teacher
      ,'1(A)' expression
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.schools s
  ON co.schoolid = s.school_number
 AND co.[db_name] = s.[db_name]
LEFT JOIN dsos
  ON s.school_number = dsos.schoolid
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
