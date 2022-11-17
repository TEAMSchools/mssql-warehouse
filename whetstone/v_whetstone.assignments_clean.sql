USE gabby
GO

CREATE OR ALTER VIEW whetstone.assignments_clean AS

SELECT [_id] AS assignment_id
      ,[type]
      ,[name]
      ,[created]
      ,[last_modified]
      ,[coaching_activity]
      ,[exclude_from_bank]
      ,[locked]
      ,[private]

      /* JSON objects */
      ,JSON_VALUE([user], '$._id') AS [user_id]
      ,JSON_VALUE([user], '$.name') AS [user_name]
      ,JSON_VALUE([creator], '$._id') AS [creator_id]
      ,JSON_VALUE([creator], '$.name') AS [creator_name]
      ,JSON_VALUE([school], '$._id') AS [school_id]
      ,JSON_VALUE([school], '$.name') AS [school_name]
      ,JSON_VALUE([grade], '$._id') AS [grade_id]
      ,JSON_VALUE([grade], '$.name') AS [grade_name]
      ,JSON_VALUE([course], '$._id') AS [course_id]
      ,JSON_VALUE([course], '$.name') AS [course_name]
      ,CAST(JSON_VALUE([progress], '$.percent') AS FLOAT) AS progress_percent
      ,JSON_VALUE([progress], '$.assigner') AS progress_assigner
      ,JSON_VALUE([progress], '$.justification') AS progress_justification
      ,CAST(JSON_VALUE([progress], '$.date') AS DATETIMEOFFSET) AS progress_date

      /* JSON arrays */
      ,[tags]
FROM [gabby].[whetstone].[assignments]
