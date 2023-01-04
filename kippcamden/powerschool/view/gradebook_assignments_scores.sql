CREATE OR ALTER VIEW
  powerschool.gradebook_assignments_scores AS
SELECT
  studentsdcid,
  scorepoints,
  islate,
  isexempt,
  ismissing,
  assignmentsectionid,
  assignmentid,
  sectionsdcid
FROM
  powerschool.gradebook_assignments_scores_current_static
UNION ALL
SELECT
  studentsdcid,
  scorepoints,
  islate,
  isexempt,
  ismissing,
  assignmentsectionid,
  assignmentid,
  sectionsdcid
FROM
  powerschool.gradebook_assignments_scores_archive
