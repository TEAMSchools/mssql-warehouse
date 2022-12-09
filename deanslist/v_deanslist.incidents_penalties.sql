CREATE OR ALTER VIEW
  deanslist.incidents_penalties AS
SELECT
  CAST(dli.incident_id AS INT) AS incident_id,
  NULL AS penalties_json,
  dlip.incidentpenaltyid,
  dlip.studentid,
  dlip.schoolid,
  dlip.penaltyid,
  dlip.penaltyname,
  dlip.said,
  dlip.startdate,
  dlip.enddate,
  dlip.numdays,
  dlip.numperiods,
  dlip.issuspension,
  dlip.[print]
FROM
  [deanslist].[incidents] dli
  CROSS APPLY OPENJSON (dli.penalties, N'$')
WITH
  (
    startdate DATE N'$.StartDate',
    enddate DATE N'$.EndDate',
    said INT N'$.SAID',
    numperiods FLOAT N'$.NumPeriods',
    incidentpenaltyid INT N'$.IncidentPenaltyID',
    penaltyid INT N'$.PenaltyID',
    [print] BIT N'$.Print',
    studentid INT N'$.StudentID',
    penaltyname VARCHAR(125) N'$.PenaltyName',
    schoolid INT N'$.SchoolID',
    issuspension BIT N'$.IsSuspension',
    incidentid INT N'$.IncidentID',
    numdays FLOAT N'$.NumDays'
  ) AS dlip
WHERE
  dli.penalties <> '[]'
