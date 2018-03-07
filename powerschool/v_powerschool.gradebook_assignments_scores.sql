USE gabby
GO

CREATE OR ALTER VIEW powerschool.gradebook_assignments_scores AS

SELECT a.studentsdcid
      ,a.scorepoints
      ,a.islate
      ,a.isexempt
      ,a.ismissing
      ,a.assignmentsectionid
      
      ,asec.assignmentid       
      ,asec.sectionsdcid
FROM gabby.powerschool.assignmentscore a
JOIN gabby.powerschool.assignmentsection asec WITH(NOLOCK)
  ON a.assignmentsectionid = asec.assignmentsectionid    