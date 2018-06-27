USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.attendance_code AS

SELECT 'kippcamden' AS [db_name]
      ,[assignment_filter_yn]
      ,[att_code]
      ,[calculate_ada_yn]
      ,[calculate_adm_yn]
      ,[course_credit_points]
      ,[dcid]
      ,[description]
      ,[id]
      ,[presence_status_cd]
      ,[schoolid]
      ,[sortorder]
      ,[yearid]
FROM kippcamden.powerschool.attendance_code
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[assignment_filter_yn]
      ,[att_code]
      ,[calculate_ada_yn]
      ,[calculate_adm_yn]
      ,[course_credit_points]
      ,[dcid]
      ,[description]
      ,[id]
      ,[presence_status_cd]
      ,[schoolid]
      ,[sortorder]
      ,[yearid]
FROM kippmiami.powerschool.attendance_code
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[assignment_filter_yn]
      ,[att_code]
      ,[calculate_ada_yn]
      ,[calculate_adm_yn]
      ,[course_credit_points]
      ,[dcid]
      ,[description]
      ,[id]
      ,[presence_status_cd]
      ,[schoolid]
      ,[sortorder]
      ,[yearid]
FROM kippnewark.powerschool.attendance_code;