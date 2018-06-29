USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradebook_assignments_scores AS

SELECT 'kippcamden' AS [db_name]
      ,[studentsdcid]
      ,[scorepoints]
      ,[islate]
      ,[isexempt]
      ,[ismissing]
      ,[assignmentsectionid]
      ,[assignmentid]
      ,[sectionsdcid]
FROM kippcamden.powerschool.gradebook_assignments_scores
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[studentsdcid]
      ,[scorepoints]
      ,[islate]
      ,[isexempt]
      ,[ismissing]
      ,[assignmentsectionid]
      ,[assignmentid]
      ,[sectionsdcid]
FROM kippmiami.powerschool.gradebook_assignments_scores
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[studentsdcid]
      ,[scorepoints]
      ,[islate]
      ,[isexempt]
      ,[ismissing]
      ,[assignmentsectionid]
      ,[assignmentid]
      ,[sectionsdcid]
FROM kippnewark.powerschool.gradebook_assignments_scores;