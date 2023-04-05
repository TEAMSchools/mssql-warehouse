CREATE OR ALTER VIEW
  deanslist.incidents_actions AS
SELECT
  dli.incident_id,
  -- trunk-ignore-begin(sqlfluff/RF01)
  dlia.[SAID] AS said,
  dlia.[ActionID] AS action_id,
  dlia.[ActionName] AS action_name,
  dlia.[SourceID] AS source_id,
  dlia.[PointValue] AS point_value
  -- trunk-ignore-end(sqlfluff/RF01)
FROM
  deanslist.stg_incidents AS dli
WITH
  (NOLOCK)
  CROSS APPLY OPENJSON (dli.actions)
  -- trunk-ignore(sqlfluff/PRS)
WITH
  (
    SAID INT,
    ActionID INT,
    ActionName NVARCHAR(128),
    SourceID INT,
    PointValue INT
  ) AS dlia
WHERE
  dli.actions != '[]'
