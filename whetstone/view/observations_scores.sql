CREATE OR ALTER VIEW
  whetstone.observations_scores AS
SELECT
  wo._id AS observation_id,
  ws.measurement AS score_measurement_id,
  ws.measurementGroup AS score_measurement_group_id,
  ws.valueScore AS score_value,
  ws.valueText AS score_value_text,
  ws.[percentage] AS score_percentage,
  ws.lastModified AS score_last_modified,
  ws.checkboxes AS score_checkboxes_json,
  ws.textBoxes AS score_text_boxes_json
FROM
  [gabby].[whetstone].observations wo
  CROSS APPLY OPENJSON (
    wo.observation_scores,
    '$'
  )
WITH
  (
    measurement NVARCHAR(128),
    measurementGroup NVARCHAR(128),
    valueScore FLOAT,
    valueText NVARCHAR(128),
    [percentage] FLOAT,
    lastModified DATETIME2,
    checkboxes NVARCHAR(MAX) AS JSON,
    textBoxes NVARCHAR(MAX) AS JSON
  ) AS ws
WHERE
  wo.observation_scores != '[]'
