USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradecalcformulaweight AS

SELECT 'kippcamden' AS [db_name]
      ,[districtteachercategoryid]
      ,[gradecalcformulaweightid]
      ,[gradecalculationtypeid]
      ,[stndcalculationmetric]
      ,[storecode]
      ,[teachercategoryid]
      ,[type]
      ,[weight]
FROM kippcamden.powerschool.gradecalcformulaweight
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[districtteachercategoryid]
      ,[gradecalcformulaweightid]
      ,[gradecalculationtypeid]
      ,[stndcalculationmetric]
      ,[storecode]
      ,[teachercategoryid]
      ,[type]
      ,[weight]
FROM kippmiami.powerschool.gradecalcformulaweight
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[districtteachercategoryid]
      ,[gradecalcformulaweightid]
      ,[gradecalculationtypeid]
      ,[stndcalculationmetric]
      ,[storecode]
      ,[teachercategoryid]
      ,[type]
      ,[weight]
FROM kippnewark.powerschool.gradecalcformulaweight;