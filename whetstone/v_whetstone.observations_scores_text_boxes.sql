USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_scores_text_boxes AS

SELECT wos.score_id
      
      ,tb._id AS text_box_id
      ,tb.label AS text_box_label
      ,tb.text AS text_box_text
FROM gabby.whetstone.observations_scores wos
CROSS APPLY OPENJSON(wos.score_textBoxes_json, '$')
  WITH (
    _id VARCHAR(25),
    label VARCHAR(125),
    text VARCHAR(MAX)
   ) AS tb
WHERE wos.score_textBoxes_json != '[]'