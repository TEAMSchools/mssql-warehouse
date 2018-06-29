USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.districtteachercategory AS

SELECT 'kippcamden' AS [db_name]
      ,[color]
      ,[defaultdaysbeforedue]
      ,[defaultpublishoption]
      ,[defaultscoreentrypoints]
      ,[defaultscoretype]
      ,[description]
      ,[displayposition]
      ,[districtteachercategoryid]
      ,[isactive]
      ,[isdefaultpublishscores]
      ,[isinfinalgrades]
      ,[isusermodifiable]
      ,[name]
FROM kippcamden.powerschool.districtteachercategory
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[color]
      ,[defaultdaysbeforedue]
      ,[defaultpublishoption]
      ,[defaultscoreentrypoints]
      ,[defaultscoretype]
      ,[description]
      ,[displayposition]
      ,[districtteachercategoryid]
      ,[isactive]
      ,[isdefaultpublishscores]
      ,[isinfinalgrades]
      ,[isusermodifiable]
      ,[name]
FROM kippmiami.powerschool.districtteachercategory
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[color]
      ,[defaultdaysbeforedue]
      ,[defaultpublishoption]
      ,[defaultscoreentrypoints]
      ,[defaultscoretype]
      ,[description]
      ,[displayposition]
      ,[districtteachercategoryid]
      ,[isactive]
      ,[isdefaultpublishscores]
      ,[isinfinalgrades]
      ,[isusermodifiable]
      ,[name]
FROM kippnewark.powerschool.districtteachercategory;