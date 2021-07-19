USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_checkboxes AS

SELECT os.observation_id
      ,os.score_measurement_id
      ,os.score_measurement_group_id
      ,os.score_value
      ,os.score_value_text
      ,os.score_percentage
      ,os.score_last_modified
      ,os.score_checkboxes_json
      ,sc.[label]
      ,sc.[value]
FROM gabby.whetstone.observations_scores os
CROSS APPLY OPENJSON(os.score_checkboxes_json, '$')
  WITH (
    [label] VARCHAR(125),
    [value] VARCHAR(125)
   ) AS sc
WHERE os.score_checkboxes_json <> '[]'
  AND sc.value IS NOT NULL
