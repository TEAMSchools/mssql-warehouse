CREATE OR ALTER VIEW
  whetstone.observations_scores_text_boxes AS
SELECT
  wos.observation_id,
  wos.score_measurement_id,
  CAST(
    JSON_VALUE(tb.[value], '$._id') AS NVARCHAR(32)
  ) AS text_box_id,
  CAST(
    JSON_VALUE(tb.[value], '$.key') AS NVARCHAR(128)
  ) AS text_box_label,
  CAST(
    JSON_VALUE(tb.[value], '$.value') AS NVARCHAR(4000)
  ) AS text_box_text
FROM
  gabby.whetstone.observations_scores_static AS wos
  CROSS APPLY OPENJSON (wos.score_text_boxes_json, '$') AS tb
WHERE
  wos.score_text_boxes_json != '[{"key":"0","value":""}]'
