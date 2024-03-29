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
  sch.[name] AS school_name,
  scw.google_email AS teacher_gsuite_email,
  CONCAT(
    sec.schoolid,
    '-',
    sec.course_number,
    '-',
    sec.id,
    '-',
    sec.termid
  ) AS class_alias,
  CONCAT(
    c.course_name,
    ' (' + c.course_number + ') - ',
    sec.section_number + ' - ',
    utilities.GLOBAL_ACADEMIC_YEAR (),
    '-',
    RIGHT(
      utilities.GLOBAL_ACADEMIC_YEAR (),
      2
    ) + 1
  ) AS class_name
FROM
  powerschool.sections AS sec
  INNER JOIN powerschool.schools AS sch ON (sec.schoolid = sch.school_number)
  INNER JOIN powerschool.courses AS c ON (
    sec.course_number = c.course_number
    AND sec.[db_name] = c.[db_name]
    AND c.credittype != 'LOG'
  )
  INNER JOIN powerschool.teachers_static AS t ON (
    sec.teacher = t.id
    AND sec.schoolid = t.schoolid
    AND sec.[db_name] = t.[db_name]
  )
  INNER JOIN people.staff_crosswalk_static AS scw ON (
    t.teachernumber = scw.ps_teachernumber
  )
WHERE
  sec.no_of_students > 0
  AND sec.termid >= (
    utilities.GLOBAL_ACADEMIC_YEAR () - 1990
  ) * 100
