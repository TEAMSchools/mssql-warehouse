USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.spenrollments_gen AS

SELECT 'kippnewark' AS [db_name]
      ,[academic_year]
      ,[dcid]
      ,[enter_date]
      ,[exit_date]
      ,[exitcode]
      ,[gradelevel]
      ,[id]
      ,[programid]
      ,[sp_comment]
      ,[specprog_name]
      ,[studentid]
FROM kippnewark.powerschool.spenrollments_gen
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[academic_year]
      ,[dcid]
      ,[enter_date]
      ,[exit_date]
      ,[exitcode]
      ,[gradelevel]
      ,[id]
      ,[programid]
      ,[sp_comment]
      ,[specprog_name]
      ,[studentid]
FROM kippmiami.powerschool.spenrollments_gen
UNION ALL
SELECT 'kippcamden' AS [db_name]
      ,[academic_year]
      ,[dcid]
      ,[enter_date]
      ,[exit_date]
      ,[exitcode]
      ,[gradelevel]
      ,[id]
      ,[programid]
      ,[sp_comment]
      ,[specprog_name]
      ,[studentid]
FROM kippcamden.powerschool.spenrollments_gen;