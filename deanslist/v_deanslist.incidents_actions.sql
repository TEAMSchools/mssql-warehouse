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
    sourceid INT N'$.SourceID',
    actionname VARCHAR(125) N'$.ActionName',
    said INT N'$.SAID',
    actionid INT N'$.ActionID'
   ) AS dlia
WHERE dli.actions != '[]'