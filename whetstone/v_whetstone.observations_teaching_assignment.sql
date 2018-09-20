USE gabby
GO

--CREATE OR ALTER VIEW whetstone.observations_teaching_assignment AS

SELECT wo._id AS observation_id
      
      ,JSON_VALUE(ta.course,'$.name') AS course
      ,JSON_VALUE(ta.gradeLevel,'$.name') AS gradeLevel
      ,JSON_VALUE(ta.school,'$.name') AS school
FROM gabby.whetstone.observations wo
CROSS APPLY OPENJSON(wo.teaching_assignment, '$')
  WITH (
    course NVARCHAR(MAX) AS JSON,
    gradeLevel NVARCHAR(MAX) AS JSON,
    school NVARCHAR(MAX) AS JSON
   ) AS ta
