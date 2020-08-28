USE gabby
GO

CREATE OR ALTER VIEW whetstone.assignment_tags AS

SELECT wa._id AS assignment_id
      ,wa.[type] AS assignment_type

      ,wt._id AS tag_id
      ,wt.[name] AS tag_name
      ,wt.[url] AS tag_url
FROM [gabby].[whetstone].[assignments] wa
CROSS APPLY OPENJSON(wa.[tags], '$')
  WITH (
    _id VARCHAR(25),
    [name] VARCHAR(125),
    [url] VARCHAR(125)
   ) AS wt
WHERE wa.[tags] != '[]'
