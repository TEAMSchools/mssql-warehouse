USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.cycle_day AS

SELECT 'kippcamden' AS [db_name]
      ,[abbreviation]
      ,[day_name]
      ,[day_number]
      ,[dcid]
      ,[id]
      ,[letter]
      ,[schoolid]
      ,[sortorder]
      ,[year_id]
FROM kippcamden.powerschool.cycle_day
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[abbreviation]
      ,[day_name]
      ,[day_number]
      ,[dcid]
      ,[id]
      ,[letter]
      ,[schoolid]
      ,[sortorder]
      ,[year_id]
FROM kippmiami.powerschool.cycle_day
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[abbreviation]
      ,[day_name]
      ,[day_number]
      ,[dcid]
      ,[id]
      ,[letter]
      ,[schoolid]
      ,[sortorder]
      ,[year_id]
FROM kippnewark.powerschool.cycle_day;