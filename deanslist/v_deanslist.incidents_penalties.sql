USE gabby
GO

ALTER VIEW deanslist.incidents_penalties AS

SELECT dli.incident_id
      ,dli.penalties AS penalties_json
      ,dlip.StartDate
      ,dlip.EndDate
      ,dlip.SAID
      ,dlip.NumPeriods
      ,dlip.IncidentPenaltyID
      ,dlip.PenaltyID
      ,dlip.[Print]
      ,dlip.StudentID
      ,dlip.PenaltyName
      ,dlip.SchoolID
      ,dlip.IsSuspension
      ,dlip.IncidentID            
      ,dlip.NumDays
FROM [gabby].[deanslist].[incidents] dli
CROSS APPLY OPENJSON(dli.penalties, N'$')
  WITH (
    StartDate DATE N'$.StartDate',
    EndDate DATE N'$.EndDate',
    SAID BIGINT N'$.SAID',    
    NumPeriods FLOAT N'$.NumPeriods',
    IncidentPenaltyID BIGINT N'$.IncidentPenaltyID',
    PenaltyID BIGINT N'$.PenaltyID',
    [Print] NVARCHAR(MAX) N'$.Print',
    StudentID BIGINT N'$.StudentID',
    PenaltyName NVARCHAR(MAX) N'$.PenaltyName',
    SchoolID INT N'$.SchoolID',    
    IsSuspension NVARCHAR(MAX) N'$.IsSuspension',
    IncidentID BIGINT N'$.IncidentID',
    NumDays FLOAT N'$.NumDays'
   ) AS dlip
WHERE dli.penalties != '[]'