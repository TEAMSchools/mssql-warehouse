USE gabby
GO

--CREATE OR ALTER VIEW whetstone.observations_magic_notes AS

SELECT wo._id AS observation_id 
      
      ,mn._id AS magic_notes_id
      ,mn.created AS magic_notes_timestamp
      ,mn.text AS text_box_text
FROM gabby.whetstone.observations wo
CROSS APPLY OPENJSON(wo.magic_notes, '$')
  WITH (
    _id VARCHAR(25),
    created DATETIME,
    text VARCHAR(500)
   ) AS mn