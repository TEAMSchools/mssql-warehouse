USE gabby
GO

CREATE OR ALTER VIEW deanslist.incidents_actions AS

SELECT dli.incident_id
      ,dli.actions AS actions_json
      
      ,dlia.sourceid
      ,dlia.actionname
      ,dlia.said
      ,dlia.actionid
FROM [gabby].[deanslist].[incidents] dli
CROSS APPLY OPENJSON(dli.actions, N'$')
  WITH (
    sourceid BIGINT N'$.SourceID',
    actionname NVARCHAR(MAX) N'$.ActionName',
    said BIGINT N'$.SAID',
    actionid BIGINT N'$.ActionID'
   ) AS dlia
WHERE dli.actions != '[]'