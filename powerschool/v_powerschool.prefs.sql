USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.prefs AS

SELECT 'kippcamden' AS [db_name]
      ,[dcid]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[userid]
      ,[value]
      ,[yearid]
FROM kippcamden.powerschool.prefs
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[dcid]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[userid]
      ,[value]
      ,[yearid]
FROM kippmiami.powerschool.prefs
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[dcid]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[userid]
      ,[value]
      ,[yearid]
FROM kippnewark.powerschool.prefs;