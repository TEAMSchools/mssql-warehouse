USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.ps_adaadm_daily_ctod AS

SELECT 'kippcamden' AS [db_name]
      ,[studentid]
      ,[schoolid]
      ,[calendardate]
      ,[fteid]
      ,[attendance_conversion_id]
      ,[grade_level]
      ,[ontrack]
      ,[offtrack]
      ,[student_track]
      ,[yearid]
      ,[attendancevalue]
      ,[membershipvalue]
      ,[potential_attendancevalue]
FROM kippcamden.powerschool.ps_adaadm_daily_ctod
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[studentid]
      ,[schoolid]
      ,[calendardate]
      ,[fteid]
      ,[attendance_conversion_id]
      ,[grade_level]
      ,[ontrack]
      ,[offtrack]
      ,[student_track]
      ,[yearid]
      ,[attendancevalue]
      ,[membershipvalue]
      ,[potential_attendancevalue]
FROM kippmiami.powerschool.ps_adaadm_daily_ctod
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[studentid]
      ,[schoolid]
      ,[calendardate]
      ,[fteid]
      ,[attendance_conversion_id]
      ,[grade_level]
      ,[ontrack]
      ,[offtrack]
      ,[student_track]
      ,[yearid]
      ,[attendancevalue]
      ,[membershipvalue]
      ,[potential_attendancevalue]
FROM kippnewark.powerschool.ps_adaadm_daily_ctod;