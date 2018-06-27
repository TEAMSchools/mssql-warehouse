USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.assignmentcategoryassoc AS

SELECT 'kippcamden' AS [db_name]
      ,[assignmentcategoryassocid]
      ,[assignmentsectionid]
      ,[isprimary]
      ,[teachercategoryid]
FROM kippcamden.powerschool.assignmentcategoryassoc
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[assignmentcategoryassocid]
      ,[assignmentsectionid]
      ,[isprimary]
      ,[teachercategoryid]
FROM kippmiami.powerschool.assignmentcategoryassoc
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[assignmentcategoryassocid]
      ,[assignmentsectionid]
      ,[isprimary]
      ,[teachercategoryid]
FROM kippnewark.powerschool.assignmentcategoryassoc;