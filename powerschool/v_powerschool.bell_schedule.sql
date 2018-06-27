USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.bell_schedule AS

SELECT 'kippcamden' AS [db_name]
      ,[attendance_conversion_id]
      ,[dcid]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[year_id]
FROM kippcamden.powerschool.bell_schedule
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[attendance_conversion_id]
      ,[dcid]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[year_id]
FROM kippmiami.powerschool.bell_schedule
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[attendance_conversion_id]
      ,[dcid]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[year_id]
FROM kippnewark.powerschool.bell_schedule;