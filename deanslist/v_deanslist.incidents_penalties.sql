USE gabby
GO

CREATE OR ALTER VIEW deanslist.incidents_penalties AS

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
FROM gabby.[deanslist].[incidents] dli
CROSS APPLY OPENJSON(dli.penalties, N'$')
  WITH (
    StartDate DATE N'$.StartDate',
    EndDate DATE N'$.EndDate',
    SAID INT N'$.SAID',    
    NumPeriods FLOAT N'$.NumPeriods',
    IncidentPenaltyID INT N'$.IncidentPenaltyID',
    PenaltyID INT N'$.PenaltyID',
    [Print] VARCHAR(5) N'$.Print',
    StudentID INT N'$.StudentID',
    PenaltyName VARCHAR(125) N'$.PenaltyName',
    SchoolID INT N'$.SchoolID',    
    IsSuspension VARCHAR(5) N'$.IsSuspension',
    IncidentID INT N'$.IncidentID',
    NumDays FLOAT N'$.NumDays'
   ) AS dlip
WHERE dli.penalties != '[]'