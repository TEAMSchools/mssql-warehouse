USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradecalculationtype AS

SELECT 'kippcamden' AS [db_name]
      ,[abbreviation]
      ,[droplowscoreoption]
      ,[gradecalculationtypeid]
      ,[gradeformulasetid]
      ,[isalternatepointsused]
      ,[iscalcformulaeditable]
      ,[isdroplowstudentfavor]
      ,[isnograde]
      ,[storecode]
      ,[type]
      ,[yearid]
FROM kippcamden.powerschool.gradecalculationtype
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[abbreviation]
      ,[droplowscoreoption]
      ,[gradecalculationtypeid]
      ,[gradeformulasetid]
      ,[isalternatepointsused]
      ,[iscalcformulaeditable]
      ,[isdroplowstudentfavor]
      ,[isnograde]
      ,[storecode]
      ,[type]
      ,[yearid]
FROM kippmiami.powerschool.gradecalculationtype
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[abbreviation]
      ,[droplowscoreoption]
      ,[gradecalculationtypeid]
      ,[gradeformulasetid]
      ,[isalternatepointsused]
      ,[iscalcformulaeditable]
      ,[isdroplowstudentfavor]
      ,[isnograde]
      ,[storecode]
      ,[type]
      ,[yearid]
FROM kippnewark.powerschool.gradecalculationtype;