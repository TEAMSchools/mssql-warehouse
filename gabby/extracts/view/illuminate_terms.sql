CREATE OR ALTER VIEW
  extracts.illuminate_terms AS
SELECT
  t.schoolid AS [01 Site ID],
  t.[name] AS [02 Term Name],
  t.id AS [03 Term Num],
  t.firstday AS [04 Start Date],
  t.lastday AS [05 End Date],
  t.portion AS [06 Term Type],
  CASE
    WHEN t.[name] LIKE '%Summer%' THEN 2
    ELSE 1
  END AS [07 Session Type ID],
  CONCAT(
    (t.yearid + 1990),
    '-',
    (t.yearid + 1991)
  ) AS [08 Academic Year],
  t.dcid AS [09 Local Term ID]
FROM
  gabby.powerschool.terms AS t
  INNER JOIN gabby.powerschool.schools AS s ON (
    t.schoolid = s.school_number
    AND t.[db_name] = s.[db_name]
    AND s.state_excludefromreporting = 0
  )
