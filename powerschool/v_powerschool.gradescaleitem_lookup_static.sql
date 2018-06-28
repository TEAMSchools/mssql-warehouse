USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradescaleitem_lookup_static AS

SELECT 'kippcamden' AS [db_name]
      ,[gradescaleid]
      ,[gradescale_name]
      ,[letter_grade]
      ,[grade_points]
      ,[min_cutoffpercentage]
      ,[max_cutoffpercentage]
FROM kippcamden.powerschool.gradescaleitem_lookup_static
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[gradescaleid]
      ,[gradescale_name]
      ,[letter_grade]
      ,[grade_points]
      ,[min_cutoffpercentage]
      ,[max_cutoffpercentage]
FROM kippmiami.powerschool.gradescaleitem_lookup_static
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[gradescaleid]
      ,[gradescale_name]
      ,[letter_grade]
      ,[grade_points]
      ,[min_cutoffpercentage]
      ,[max_cutoffpercentage]
FROM kippnewark.powerschool.gradescaleitem_lookup_static;