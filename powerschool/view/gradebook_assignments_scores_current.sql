CREATE OR ALTER VIEW
  powerschool.gradebook_assignments_scores_current AS
SELECT
  CAST(a.studentsdcid AS INT) AS studentsdcid,
  a.scorepoints,
  CAST(a.islate AS INT) AS islate,
  CAST(a.isexempt AS INT) AS isexempt,
  CAST(a.ismissing AS INT) AS ismissing,
  CAST(a.assignmentsectionid AS INT) AS assignmentsectionid,
  CAST(asec.assignmentid AS INT) AS assignmentid,
  CAST(asec.sectionsdcid AS INT) AS sectionsdcid
FROM
  powerschool.assignmentscore AS a
  INNER JOIN powerschool.assignmentsection AS asec ON a.assignmentsectionid = asec.assignmentsectionid
WHERE
  a.scoreentrydate >= DATEFROMPARTS(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
