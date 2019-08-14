USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_clean AS

SELECT id
      ,title
      ,type
      ,status
      ,team
      ,CONVERT(DATETIME2, created_on) AS created_on
      ,CONVERT(DATETIME2, modified_on) AS modified_on
      ,links AS links_json
      ,[statistics] AS statistics_json
      ,JSON_VALUE(links, '$.edit') AS edit_link
      ,JSON_VALUE(links, '$.publish') AS publish_link
      ,JSON_VALUE(links, '$.default') AS default_link
      ,JSON_VALUE([statistics], '$.Partial') AS [partial]
      ,JSON_VALUE([statistics], '$.Deleted') AS deleted
      ,JSON_VALUE([statistics], '$.Complete') AS complete
      ,JSON_VALUE([statistics], '$.TestData') AS test_data
FROM gabby.surveygizmo.survey