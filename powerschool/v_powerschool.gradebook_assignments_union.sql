USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradebook_assignments AS

SELECT 'kippcamden' AS [db_name]
      ,[assign_date]
      ,[assign_name]
      ,[assignmentid]
      ,[assignmentsectionid]
      ,[category_name]
      ,[categoryid]
      ,[extracreditpoints]
      ,[isfinalscorecalculated]
      ,[pointspossible]
      ,[sectionsdcid]
      ,[weight]
FROM kippcamden.powerschool.gradebook_assignments
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[assign_date]
      ,[assign_name]
      ,[assignmentid]
      ,[assignmentsectionid]
      ,[category_name]
      ,[categoryid]
      ,[extracreditpoints]
      ,[isfinalscorecalculated]
      ,[pointspossible]
      ,[sectionsdcid]
      ,[weight]
FROM kippmiami.powerschool.gradebook_assignments
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[assign_date]
      ,[assign_name]
      ,[assignmentid]
      ,[assignmentsectionid]
      ,[category_name]
      ,[categoryid]
      ,[extracreditpoints]
      ,[isfinalscorecalculated]
      ,[pointspossible]
      ,[sectionsdcid]
      ,[weight]
FROM kippnewark.powerschool.gradebook_assignments;