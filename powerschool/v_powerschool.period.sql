USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.period AS

SELECT 'kippcamden' AS [db_name]
      ,[abbreviation]
      ,[dcid]
      ,[id]
      ,[name]
      ,[period_number]
      ,[schoolid]
      ,[sort_order]
      ,[year_id]
FROM kippcamden.powerschool.period
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[abbreviation]
      ,[dcid]
      ,[id]
      ,[name]
      ,[period_number]
      ,[schoolid]
      ,[sort_order]
      ,[year_id]
FROM kippmiami.powerschool.period
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[abbreviation]
      ,[dcid]
      ,[id]
      ,[name]
      ,[period_number]
      ,[schoolid]
      ,[sort_order]
      ,[year_id]
FROM kippnewark.powerschool.period;