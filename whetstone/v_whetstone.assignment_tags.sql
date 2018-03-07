USE gabby
GO

CREATE OR ALTER VIEW whetstone.assignment_tags AS

SELECT wa._id AS assignment_id
      ,wa.type
      ,wa.tags AS assignment_tags_json
      
      ,wt.tag_id
      ,wt.tag_name
FROM [gabby].[whetstone].[assignments] wa
CROSS APPLY OPENJSON(wa.[tags], '$')
  WITH (
    tag_id VARCHAR(25) '$._id',
    tag_name VARCHAR(125) '$.name'
   ) AS wt
WHERE wa.[tags] != '[]'