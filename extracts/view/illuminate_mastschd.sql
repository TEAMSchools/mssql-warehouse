CREATE OR ALTER VIEW
  extracts.illuminate_mastschd AS
  /* trunk-ignore(sqlfluff/L034) */
SELECT
  CONCAT(
    CASE
      WHEN tr.[db_name] = 'kippnewark' THEN 'NWK'
      WHEN tr.[db_name] = 'kippcamden' THEN 'CMD'
      WHEN tr.[db_name] = 'kippmiami' THEN 'MIA'
    END,
    sec.id
  ) AS [01 Section ID],
  tr.schoolid AS [02 Site ID],
  tr.[name] AS [03 Term Name],
  sec.course_number AS [04 Course ID],
  t.teachernumber AS [05 User ID],
  CASE
    WHEN tr.schoolid = 73253 THEN sec.expression
    ELSE sec.section_number
  END AS [06 Period],
  CONCAT((tr.yearid + 1990), '-', (tr.yearid + 1991)) AS [07 Academic Year],
  NULL AS [08 Room Number],
  NULL AS [09 Session Type ID],
  NULL AS [10 Local Term ID],
  NULL AS [11 Quarter Num],
  tr.firstday AS [12 User Start Date],
  tr.lastday AS [13 User End Date],
  1 AS [14 Primary Teacher],
  NULL AS [15 Teacher Competency Level],
  NULL AS [16 Is Attendance Enabled]
FROM
  gabby.powerschool.terms AS tr
  INNER JOIN gabby.powerschool.sections AS sec ON tr.id = sec.termid
  AND tr.schoolid = sec.schoolid
  AND tr.[db_name] = sec.[db_name]
  INNER JOIN gabby.powerschool.teachers_static AS t ON sec.teacher = t.id
  AND sec.[db_name] = t.[db_name]
WHERE
  tr.yearid = (
    gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
  )
