USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradeformulaset AS

SELECT 'kippcamden' AS [db_name]
      ,[gradeformulasetid]
      ,[isavailgenanycourse]
      ,[isavailgenasdefault]
      ,[isavailgeneraluse]
      ,[isavailspecstndcourse]
      ,[iscoursegradecalculated]
      ,[isreporttermsetupsame]
      ,[name]
      ,[sectionsdcid]
      ,[yearid]
FROM kippcamden.powerschool.gradeformulaset
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[gradeformulasetid]
      ,[isavailgenanycourse]
      ,[isavailgenasdefault]
      ,[isavailgeneraluse]
      ,[isavailspecstndcourse]
      ,[iscoursegradecalculated]
      ,[isreporttermsetupsame]
      ,[name]
      ,[sectionsdcid]
      ,[yearid]
FROM kippmiami.powerschool.gradeformulaset
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[gradeformulasetid]
      ,[isavailgenanycourse]
      ,[isavailgenasdefault]
      ,[isavailgeneraluse]
      ,[isavailspecstndcourse]
      ,[iscoursegradecalculated]
      ,[isreporttermsetupsame]
      ,[name]
      ,[sectionsdcid]
      ,[yearid]
FROM kippnewark.powerschool.gradeformulaset;