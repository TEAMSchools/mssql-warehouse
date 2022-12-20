CREATE OR ALTER VIEW
  deanslist.incidents_actions AS
SELECT
  dli.incident_id,
  CAST(JSON_QUERY(dlia.[value], '$.SAID') AS INT) AS said,
  CAST(
    JSON_QUERY(dlia.[value], '$.ActionID') AS INT
  ) AS action_id,
  CAST(
    JSON_QUERY(dlia.[value], '$.ActionName') AS NVARCHAR(128)
  ) AS action_name,
  CAST(
    JSON_QUERY(dlia.[value], '$.SourceID') AS INT
  ) AS source_id
FROM
  deanslist.incidents AS dli
  CROSS APPLY OPENJSON (dli.actions, N'$') AS dlia
WHERE
  dli.actions != '[]'
