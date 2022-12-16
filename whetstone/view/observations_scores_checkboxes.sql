CREATE OR ALTER VIEW
  whetstone.observations_scores_checkboxes AS
SELECT
  os.observation_id,
  os.score_measurement_id,
  sc.[label] AS checkbox_label,
  sc.[value] AS checkbox_value
FROM
  gabby.whetstone.observations_scores_static AS os
  CROSS APPLY OPENJSON (os.score_checkboxes_json, '$')
WITH
  ([label] NVARCHAR(256), [value] BIT) AS sc
WHERE
  os.score_checkboxes_json != '[]'
