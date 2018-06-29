CREATE OR ALTER VIEW powerschool.gradebook_assignments_scores_current AS

SELECT CONVERT(INT,a.studentsdcid) AS studentsdcid
      ,a.scorepoints
      ,CONVERT(INT,a.islate) AS islate
      ,CONVERT(INT,a.isexempt) AS isexempt
      ,CONVERT(INT,a.ismissing) AS ismissing
      ,CONVERT(INT,a.assignmentsectionid) AS assignmentsectionid
      
      ,CONVERT(INT,asec.assignmentid) AS assignmentid
      ,CONVERT(INT,asec.sectionsdcid) AS sectionsdcid
FROM powerschool.assignmentscore a
JOIN powerschool.assignmentsection asec
  ON a.assignmentsectionid = asec.assignmentsectionid    
WHERE a.scoreentrydate >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)