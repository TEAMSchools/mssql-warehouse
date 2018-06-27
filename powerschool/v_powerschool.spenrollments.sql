USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.spenrollments AS

SELECT 'kippcamden' AS [db_name]
      ,[dcid]
      ,[enter_date]
      ,[exit_date]
      ,[exitcode]
      ,[gradelevel]
      ,[id]
      ,[programid]
      ,[schoolid]
      ,[sp_comment]
      ,[studentid]
FROM kippcamden.powerschool.spenrollments
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[dcid]
      ,[enter_date]
      ,[exit_date]
      ,[exitcode]
      ,[gradelevel]
      ,[id]
      ,[programid]
      ,[schoolid]
      ,[sp_comment]
      ,[studentid]
FROM kippmiami.powerschool.spenrollments
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[dcid]
      ,[enter_date]
      ,[exit_date]
      ,[exitcode]
      ,[gradelevel]
      ,[id]
      ,[programid]
      ,[schoolid]
      ,[sp_comment]
      ,[studentid]
FROM kippnewark.powerschool.spenrollments;