USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_scores_checkboxes AS

SELECT os.observation_id
      ,os.score_measurement_id

      ,sc.[label] AS checkbox_label
      ,sc.[value] AS checkbox_value
FROM gabby.whetstone.observations_scores os
CROSS APPLY OPENJSON(os.score_checkboxes_json, '$')
  WITH (
     [label] VARCHAR(125)
    ,[value] VARCHAR(125)
   ) AS sc
WHERE os.score_checkboxes_json <> '[]'
