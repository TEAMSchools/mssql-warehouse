USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.team_roster_static AS

SELECT 'kippcamden' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[academic_year]
      ,[team]
      ,[rn_year]
FROM kippcamden.powerschool.team_roster_static
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[academic_year]
      ,[team]
      ,[rn_year]
FROM kippmiami.powerschool.team_roster_static
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[academic_year]
      ,[team]
      ,[rn_year]
FROM kippnewark.powerschool.team_roster_static;