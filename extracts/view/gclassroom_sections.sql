USE gabby GO
CREATE OR ALTER VIEW
  extracts.gclassroom_sections AS
SELECT
  sec.id AS sectionid,
  sec.[db_name],
  sec.section_number,
  sec.external_expression AS [period],
  sec.schoolid,
  sec.termid,
  sec.course_number,
  sec.room,
  CONCAT(
    sec.schoolid,
    '-',
    sec.course_number,
    '-',
    sec.id,
    '-',
    sec.termid
  ) AS class_alias,
  sch.[name] AS school_name,
  scw.google_email AS teacher_gsuite_email,
  CONCAT(
    c.course_name,
    ' (' + c.course_number + ') - ',
    sec.section_number + ' - ',
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    '-',
    RIGHT(gabby.utilities.GLOBAL_ACADEMIC_YEAR (), 2) + 1
  ) AS class_name
FROM
  gabby.powerschool.sections sec
  INNER JOIN gabby.powerschool.schools sch ON sec.schoolid = sch.school_number
  INNER JOIN gabby.powerschool.courses c ON sec.course_number = c.course_number
  AND sec.[db_name] = c.[db_name]
  AND c.credittype <> 'LOG'
  INNER JOIN gabby.powerschool.teachers_static t ON sec.teacher = t.id
  AND sec.schoolid = t.schoolid
  AND sec.[db_name] = t.[db_name]
  INNER JOIN gabby.people.staff_crosswalk_static scw ON t.teachernumber = scw.ps_teachernumber
COLLATE Latin1_General_BIN
WHERE
  sec.termid >= (
    (gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990) * 100
  )
  AND sec.no_of_students > 0
