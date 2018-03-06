USE gabby
GO

CREATE OR ALTER VIEW deanslist.extracurricular_roster AS

SELECT CONVERT(INT,ra.student_school_id) AS student_number
      ,CONVERT(VARCHAR(125),ra.roster_name) AS roster_name
      
      ,CONVERT(VARCHAR(25),r.roster_type) AS roster_type
FROM gabby.deanslist.rosters_all r
JOIN gabby.deanslist.roster_assignments ra
  ON r.roster_id = ra.dlroster_id
WHERE r.roster_type IN ('Club','Athletics')