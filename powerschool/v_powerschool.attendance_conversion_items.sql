USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.attendance_conversion_items AS

SELECT 'kippcamden' AS [db_name]
      ,[attendance_conversion_id]
      ,[attendance_value]
      ,[conversion_mode_code]
      ,[daypartid]
      ,[dcid]
      ,[fteid]
      ,[id]
      ,[input_value]
      ,[unused]
FROM kippcamden.powerschool.attendance_conversion_items
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[attendance_conversion_id]
      ,[attendance_value]
      ,[conversion_mode_code]
      ,[daypartid]
      ,[dcid]
      ,[fteid]
      ,[id]
      ,[input_value]
      ,[unused]
FROM kippmiami.powerschool.attendance_conversion_items
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[attendance_conversion_id]
      ,[attendance_value]
      ,[conversion_mode_code]
      ,[daypartid]
      ,[dcid]
      ,[fteid]
      ,[id]
      ,[input_value]
      ,[unused]
FROM kippnewark.powerschool.attendance_conversion_items;