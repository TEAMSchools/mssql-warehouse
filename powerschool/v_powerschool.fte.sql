USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.fte AS

SELECT 'kippcamden' AS [db_name]
      ,[dcid]
      ,[description]
      ,[dflt_att_mode_code]
      ,[dflt_conversion_mode_code]
      ,[fte_value]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[yearid]
FROM kippcamden.powerschool.fte
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[dcid]
      ,[description]
      ,[dflt_att_mode_code]
      ,[dflt_conversion_mode_code]
      ,[fte_value]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[yearid]
FROM kippmiami.powerschool.fte
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[dcid]
      ,[description]
      ,[dflt_att_mode_code]
      ,[dflt_conversion_mode_code]
      ,[fte_value]
      ,[id]
      ,[name]
      ,[schoolid]
      ,[yearid]
FROM kippnewark.powerschool.fte;