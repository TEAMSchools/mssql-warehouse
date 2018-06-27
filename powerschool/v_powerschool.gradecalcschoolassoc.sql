USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradecalcschoolassoc AS

SELECT 'kippcamden' AS [db_name]
      ,[gradecalcschoolassocid]
      ,[gradecalculationtypeid]
      ,[schoolsdcid]
FROM kippcamden.powerschool.gradecalcschoolassoc
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[gradecalcschoolassocid]
      ,[gradecalculationtypeid]
      ,[schoolsdcid]
FROM kippmiami.powerschool.gradecalcschoolassoc
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[gradecalcschoolassocid]
      ,[gradecalculationtypeid]
      ,[schoolsdcid]
FROM kippnewark.powerschool.gradecalcschoolassoc;