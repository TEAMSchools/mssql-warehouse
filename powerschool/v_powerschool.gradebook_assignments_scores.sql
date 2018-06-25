USE gabby
GO

CREATE OR ALTER VIEW powerschool.gradebook_assignments_scores AS

SELECT gasc.studentsdcid
      ,gasc.scorepoints
      ,gasc.islate
      ,gasc.isexempt
      ,gasc.ismissing
      ,gasc.assignmentsectionid      
      ,gasc.assignmentid       
      ,gasc.sectionsdcid
FROM powerschool.gradebook_assignments_scores_current_static gasc

UNION ALL

SELECT gasa.studentsdcid
      ,gasa.scorepoints
      ,gasa.islate
      ,gasa.isexempt
      ,gasa.ismissing
      ,gasa.assignmentsectionid      
      ,gasa.assignmentid       
      ,gasa.sectionsdcid
FROM powerschool.gradebook_assignments_scores_archive gasa