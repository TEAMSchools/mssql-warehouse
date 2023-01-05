CREATE OR ALTER VIEW
  whetstone.observations_magic_notes AS
SELECT
  wo._id AS observation_id,
  CAST(
    JSON_VALUE(mn.[value], '$._id') AS NVARCHAR(32)
  ) AS magic_notes_id,
  CAST(
    JSON_VALUE(mn.[value], '$.created') AS DATETIME2
  ) AS magic_notes_created,
  CAST(
    JSON_VALUE(mn.[value], '$.text') AS NVARCHAR(4000)
  ) AS magic_notes_text,
  CAST(
    JSON_VALUE(mn.[value], '$.shared') AS BIT
  ) AS magic_notes_shared
FROM
  whetstone.observations AS wo
  CROSS APPLY OPENJSON (wo.magic_notes, '$') AS mn
WHERE
  wo.magic_notes != '[]'
