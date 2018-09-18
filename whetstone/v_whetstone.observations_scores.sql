USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_scores AS

SELECT wo._id AS observation_id
      ,wo.scores AS observation_scores_json

      ,ws._id AS score_id
      ,ws.measurement AS score_measurement_id
      ,ws.percentage AS score_percentage
      ,ws.value AS score_value
      ,ws.textBoxes AS score_textBoxes_json
FROM [gabby].[whetstone].observations wo
CROSS APPLY OPENJSON(wo.scores, '$')
  WITH (
    _id VARCHAR(25),
    measurement VARCHAR(125),
    percentage FLOAT,
    value FLOAT,
    textBoxes NVARCHAR(MAX) AS JSON
   ) AS ws
WHERE wo.scores != '[]'