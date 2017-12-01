USE gabby
GO

CREATE OR ALTER VIEW whetstone.assignments_tags AS 

SELECT a._id AS assignments_id
      ,a.tags AS tags_json      

      ,t._id AS tag_id
      ,t.name AS tag_name
FROM gabby.whetstone.assignments a
CROSS APPLY OPENJSON(a.tags, N'$')
  WITH (
    _id NVARCHAR(MAX) N'$._id',
    name NVARCHAR(MAX) N'$.name'
   ) AS t
WHERE a.tags != '[]'