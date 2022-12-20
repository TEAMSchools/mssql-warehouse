CREATE OR ALTER VIEW
  deanslist.incidents_penalties AS
SELECT
  CAST(dli.incident_id AS INT) AS incident_id,
  CAST(
    JSON_VALUE(dlip.[value], '$.IncidentPenaltyID') AS BIGINT
  ) AS incident_penalty_id,
  CAST(
    JSON_VALUE(dlip.[value], '$.StudentID') AS BIGINT
  ) AS student_id,
  CAST(
    JSON_VALUE(dlip.[value], '$.SchoolID') AS BIGINT
  ) AS school_id,
  CAST(
    JSON_VALUE(dlip.[value], '$.PenaltyID') AS BIGINT
  ) AS penalty_id,
  CAST(
    JSON_VALUE(dlip.[value], '$.PenaltyName') AS NVARCHAR(128)
  ) AS penalty_name,
  CAST(
    JSON_VALUE(dlip.[value], '$.SAID') AS BIGINT
  ) AS said,
  CAST(
    JSON_VALUE(dlip.[value], '$.StartDate') AS DATE
  ) AS [start_date],
  CAST(
    JSON_VALUE(dlip.[value], '$.EndDate') AS DATE
  ) AS end_date,
  CAST(
    JSON_VALUE(dlip.[value], '$.NumDays') AS BIGINT
  ) AS num_days,
  CAST(
    JSON_VALUE(dlip.[value], '$.NumPeriods') AS FLOAT
  ) AS num_periods,
  CAST(
    JSON_VALUE(dlip.[value], '$.IsSuspension') AS BIT
  ) AS is_suspension,
  CAST(JSON_VALUE(dlip.[value], '$.Print') AS BIT) AS [print]
FROM
  [deanslist].[incidents] AS dli
  CROSS APPLY OPENJSON (dli.penalties, N'$') AS dlip
WHERE
  dli.penalties != '[]'
