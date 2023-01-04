CREATE OR ALTER VIEW
  whetstone.observations_scores_checkboxes AS
SELECT
  os.observation_id,
  os.score_measurement_id,
  CAST(
    JSON_VALUE(sc.[value], '$.label') AS NVARCHAR(256)
  ) AS checkbox_label,
  CAST(
    JSON_VALUE(sc.[value], '$.value') AS BIT
  ) AS checkbox_value
FROM
  gabby.whetstone.observations_scores_static AS os
  CROSS APPLY OPENJSON (os.score_checkboxes_json, '$') AS sc
WHERE
  os.score_checkboxes_json != '[]'
