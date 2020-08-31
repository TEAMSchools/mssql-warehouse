USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_scores_text_boxes AS

SELECT wos.observation_id
      ,wos.score_measurement_id

      ,tb._id AS text_box_id
      ,tb.[key] AS text_box_label
      ,tb.[value] AS text_box_text
FROM gabby.whetstone.observations_scores wos
CROSS APPLY OPENJSON(wos.score_textBoxes_json, '$')
  WITH (
    _id VARCHAR(25),
    [key] VARCHAR(125),
    [value] VARCHAR(4000)
   ) AS tb
WHERE wos.score_textBoxes_json <> '[{"key":"0","value":""}]'
