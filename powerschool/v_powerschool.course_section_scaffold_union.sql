USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.course_section_scaffold AS

SELECT 'kippnewark' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[yearid]
      ,[term_name]
      ,[is_curterm]
      ,[course_number]
      ,[excludefromgpa]
      ,[sectionid]
      ,[course_name]
      ,[credittype]
      ,[credit_hours]
      ,[gradescaleid]
FROM kippnewark.powerschool.course_section_scaffold
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[yearid]
      ,[term_name]
      ,[is_curterm]
      ,[course_number]
      ,[excludefromgpa]
      ,[sectionid]
      ,[course_name]
      ,[credittype]
      ,[credit_hours]
      ,[gradescaleid]
FROM kippmiami.powerschool.course_section_scaffold
UNION ALL
SELECT 'kippcamden' AS [db_name]
      ,[studentid]
      ,[student_number]
      ,[yearid]
      ,[term_name]
      ,[is_curterm]
      ,[course_number]
      ,[excludefromgpa]
      ,[sectionid]
      ,[course_name]
      ,[credittype]
      ,[credit_hours]
      ,[gradescaleid]
FROM kippcamden.powerschool.course_section_scaffold;