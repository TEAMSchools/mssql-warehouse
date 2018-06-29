USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.student_access_accounts_static AS

SELECT 'kippcamden' AS [db_name]
      ,[student_number]
      ,[schoolid]
      ,[enroll_status]
      ,[base_username]
      ,[alt_username]
      ,[uses_alt]
      ,[base_dupe_audit]
      ,[alt_dupe_audit]
      ,[student_web_id]
      ,[student_web_password]
FROM kippcamden.powerschool.student_access_accounts_static
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[student_number]
      ,[schoolid]
      ,[enroll_status]
      ,[base_username]
      ,[alt_username]
      ,[uses_alt]
      ,[base_dupe_audit]
      ,[alt_dupe_audit]
      ,[student_web_id]
      ,[student_web_password]
FROM kippmiami.powerschool.student_access_accounts_static
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[student_number]
      ,[schoolid]
      ,[enroll_status]
      ,[base_username]
      ,[alt_username]
      ,[uses_alt]
      ,[base_dupe_audit]
      ,[alt_dupe_audit]
      ,[student_web_id]
      ,[student_web_password]
FROM kippnewark.powerschool.student_access_accounts_static;