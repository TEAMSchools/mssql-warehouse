USE gabby
GO

ALTER VIEW deanslist.incidents_actions AS

SELECT dli.incident_id
      ,dli.actions AS actions_json
      ,dlia.*
FROM [gabby].[deanslist].[incidents] dli
CROSS APPLY OPENJSON(dli.actions, N'$')
  WITH (
    SourceID BIGINT N'$.SourceID',
    ActionName NVARCHAR(MAX) N'$.ActionName',
    SAID BIGINT N'$.SAID',
    ActionID BIGINT N'$.ActionID'
   ) AS dlia
WHERE dli.actions != '[]'