USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_magic_notes AS

SELECT wo._id AS observation_id 

      ,mn._id AS magic_notes_id
      ,mn.created AS magic_notes_created
      ,mn.[text] AS magic_notes_text
      ,mn.shared AS magic_notes_shared
FROM gabby.whetstone.observations wo
CROSS APPLY OPENJSON(wo.magic_notes, '$')
  WITH (
    _id VARCHAR(25),
    shared BIT,
    created DATETIME2,
    [text] VARCHAR(4000)
   ) AS mn
WHERE wo.magic_notes <> '[]'
