USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.advisory_static AS

SELECT 'kippcamden' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[academic_year]
      ,[teachernumber]
      ,[advisor_name]
      ,[dateenrolled]
      ,[dateleft]
      ,[advisor_phone]
      ,[advisor_email]
      ,[rn_year]
FROM kippcamden.powerschool.advisory_static
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[academic_year]
      ,[teachernumber]
      ,[advisor_name]
      ,[dateenrolled]
      ,[dateleft]
      ,[advisor_phone]
      ,[advisor_email]
      ,[rn_year]
FROM kippmiami.powerschool.advisory_static
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[academic_year]
      ,[teachernumber]
      ,[advisor_name]
      ,[dateenrolled]
      ,[dateleft]
      ,[advisor_phone]
      ,[advisor_email]
      ,[rn_year]
FROM kippnewark.powerschool.advisory_static;