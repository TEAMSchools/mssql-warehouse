USE gabby
GO

CREATE OR ALTER VIEW deanslist.incidents_actions AS

SELECT DISTINCT 
       CONVERT(INT, dli.incident_id) AS incident_id
      ,CONVERT(VARCHAR(1000), dli.actions) AS actions_json

      ,dlia.said
      ,dlia.actionid
      ,dlia.actionname
FROM [gabby].[deanslist].[incidents] dli
CROSS APPLY OPENJSON(dli.actions, N'$')
  WITH (
    said INT N'$.SAID',
    actionid INT N'$.ActionID',
    actionname VARCHAR(125) N'$.ActionName',
    sourceid INT N'$.SourceID'
   ) AS dlia
WHERE dli.actions <> '[]'
