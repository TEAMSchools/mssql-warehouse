USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.attendance_clean AS

SELECT 'kippcamden' AS [db_name]
      ,[id]
      ,[studentid]
      ,[schoolid]
      ,[att_date]
      ,[attendance_codeid]
      ,[att_mode_code]
      ,[calendar_dayid]
      ,[att_interval]
      ,[ccid]
      ,[periodid]
      ,[programid]
      ,[total_minutes]
      ,[att_comment]
FROM kippcamden.powerschool.attendance_clean
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[id]
      ,[studentid]
      ,[schoolid]
      ,[att_date]
      ,[attendance_codeid]
      ,[att_mode_code]
      ,[calendar_dayid]
      ,[att_interval]
      ,[ccid]
      ,[periodid]
      ,[programid]
      ,[total_minutes]
      ,[att_comment]
FROM kippmiami.powerschool.attendance_clean
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[id]
      ,[studentid]
      ,[schoolid]
      ,[att_date]
      ,[attendance_codeid]
      ,[att_mode_code]
      ,[calendar_dayid]
      ,[att_interval]
      ,[ccid]
      ,[periodid]
      ,[programid]
      ,[total_minutes]
      ,[att_comment]
FROM kippnewark.powerschool.attendance_clean;