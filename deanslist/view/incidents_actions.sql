CREATE OR ALTER VIEW
  deanslist.incidents_actions AS
SELECT
  dli.incident_id,
  dlia.said,
  dlia.actionid,
  dlia.actionname
FROM
  deanslist.incidents dli
  CROSS APPLY OPENJSON (dli.actions, N'$')
WITH
  (
    said INT N'$.SAID',
    actionid INT N'$.ActionID',
    actionname NVARCHAR(128) N'$.ActionName',
    sourceid INT N'$.SourceID'
  ) AS dlia
WHERE
  dli.actions <> '[]'
