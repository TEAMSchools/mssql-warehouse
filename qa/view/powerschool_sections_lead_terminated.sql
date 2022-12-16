CREATE OR ALTER VIEW
  qa.powerschool_sections_lead_terminated AS
SELECT
  sec.[db_name],
  sec.id,
  sec.course_number,
  sec.section_number,
  sec.schoolid,
  t.teachernumber,
  scw.preferred_name
FROM
  gabby.powerschool.sections AS sec
  INNER JOIN gabby.powerschool.teachers_static AS t ON sec.teacher = t.id
  AND sec.[db_name] = t.[db_name]
  INNER JOIN gabby.people.staff_crosswalk_static AS scw ON t.teachernumber = scw.ps_teachernumber
COLLATE Latin1_General_BIN
AND scw.[status] = 'TERMINATED'
WHERE
  sec.termid >= (
    (
      gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
    ) * 100
  )
