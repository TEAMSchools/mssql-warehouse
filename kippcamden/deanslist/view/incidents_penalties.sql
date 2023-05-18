CREATE OR ALTER VIEW
  deanslist.incidents_penalties AS
SELECT
  CAST(dli.incident_id AS INT) AS incident_id,
  NULL AS penalties_json,
  CAST(
    JSON_VALUE(
      dlip.[value],
      '$.IncidentPenaltyID'
    ) AS BIGINT
  ) AS incidentpenaltyid,
  CAST(
    JSON_VALUE(dlip.[value], '$.StudentID') AS BIGINT
  ) AS studentid,
  CAST(
    JSON_VALUE(dlip.[value], '$.SchoolID') AS BIGINT
  ) AS schoolid,
  CAST(
    JSON_VALUE(dlip.[value], '$.PenaltyID') AS BIGINT
  ) AS penaltyid,
  CAST(
    JSON_VALUE(dlip.[value], '$.PenaltyName') AS NVARCHAR(128)
  ) AS penaltyname,
  CAST(
    JSON_VALUE(dlip.[value], '$.SAID') AS BIGINT
  ) AS said,
  CAST(
    JSON_VALUE(dlip.[value], '$.StartDate') AS DATE
  ) AS startdate,
  CAST(
    JSON_VALUE(dlip.[value], '$.EndDate') AS DATE
  ) AS enddate,
  JSON_VALUE(dlip.[value], '$.NumDays') AS numdays,
  CAST(
    JSON_VALUE(dlip.[value], '$.NumPeriods') AS FLOAT
  ) AS numperiods,
  CAST(
    JSON_VALUE(dlip.[value], '$.IsSuspension') AS BIT
  ) AS issuspension,
  CAST(
    JSON_VALUE(dlip.[value], '$.Print') AS BIT
  ) AS [print]
FROM
  deanslist.stg_incidents AS dli
  CROSS APPLY OPENJSON (dli.penalties, N'$') AS dlip
WHERE
  dli.penalties != '[]'
