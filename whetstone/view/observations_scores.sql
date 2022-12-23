CREATE OR ALTER VIEW
  whetstone.observations_scores AS
SELECT
  wo._id AS observation_id,
  CAST(
    JSON_VALUE(ws.[value], '$.measurement') AS NVARCHAR(128)
  ) AS score_measurement_id,
  CAST(
    JSON_VALUE(ws.[value], '$.measurementGroup') AS NVARCHAR(128)
  ) AS score_measurement_group_id,
  CAST(
    JSON_VALUE(ws.[value], '$.valueScore') AS FLOAT
  ) AS score_value,
  CAST(
    JSON_VALUE(ws.[value], '$.valueText') AS NVARCHAR(128)
  ) AS score_value_text,
  CAST(
    JSON_VALUE(ws.[value], '$.[percentage]') AS FLOAT
  ) AS score_percentage,
  CAST(
    JSON_VALUE(ws.[value], '$.lastModified') AS DATETIME2
  ) AS score_last_modified,
  JSON_QUERY(ws.[value], '$.checkboxes') AS score_checkboxes_json,
  JSON_QUERY(ws.[value], '$.textBoxes') AS score_text_boxes_json
FROM
  gabby.whetstone.observations AS wo
  CROSS APPLY OPENJSON (wo.observation_scores, '$') AS ws
WHERE
  wo.observation_scores != '[]'
