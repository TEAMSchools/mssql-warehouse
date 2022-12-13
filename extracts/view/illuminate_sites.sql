USE gabby;

GO
CREATE OR ALTER VIEW
  extracts.illuminate_sites AS
SELECT
  school_number AS [01 Site ID],
  name AS [02 Site Name],
  school_number AS [03 State Site ID],
  CASE
    WHEN low_grade IN (-2, -1) THEN 15
    WHEN low_grade = 99 THEN 14
    ELSE low_grade + 1
  END AS [04 Start Grade Level ID],
  CASE
    WHEN high_grade IN (-2, -1) THEN 15
    WHEN high_grade = 99 THEN 14
    ELSE high_grade + 1
  END AS [05 End Grade Level ID],
  CASE
    WHEN high_grade = 8 THEN 1
    WHEN high_grade = 12 THEN 2
    WHEN high_grade = 0 THEN 4
    WHEN high_grade = 4 THEN 9
    ELSE 7
  END AS [06 School Type ID],
  NULL AS [07 Address 1],
  NULL AS [08 Address 2],
  schoolcity AS [09 City],
  schoolstate AS [10 State],
  schoolzip AS [11 Zip Code],
  NULL AS [12 Local Site Code],
  NULL AS [13 Annual Hours of Instruction],
  NULL AS [14 Annual Number of Weeks of Instruction],
  NULL AS [15 Parent Site ID]
FROM
  gabby.powerschool.schools
WHERE
  state_excludefromreporting = 0;
