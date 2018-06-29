USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.attendance_streak AS

SELECT 'kippnewark' AS [db_name]
      ,[academic_year]
      ,[att_code]
      ,[streak_end]
      ,[streak_id]
      ,[streak_length]
      ,[streak_length_membership]
      ,[streak_start]
      ,[student_number]
FROM kippnewark.powerschool.attendance_streak
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[academic_year]
      ,[att_code]
      ,[streak_end]
      ,[streak_id]
      ,[streak_length]
      ,[streak_length_membership]
      ,[streak_start]
      ,[student_number]
FROM kippmiami.powerschool.attendance_streak
UNION ALL
SELECT 'kippcamden' AS [db_name]
      ,[academic_year]
      ,[att_code]
      ,[streak_end]
      ,[streak_id]
      ,[streak_length]
      ,[streak_length_membership]
      ,[streak_start]
      ,[student_number]
FROM kippcamden.powerschool.attendance_streak;