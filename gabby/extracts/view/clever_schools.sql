CREATE OR ALTER VIEW
  extracts.clever_schools AS
SELECT
  CAST(school_number AS VARCHAR(25)) AS [School_id],
  [name] AS [School_name],
  CAST(school_number AS VARCHAR(25)) AS [School_number],
  NULL AS [State_id],
  CASE
    WHEN low_grade = 0 THEN 'Kindergarten'
    ELSE CAST(low_grade AS VARCHAR(5))
  END AS [Low_grade],
  high_grade AS [High_grade],
  principal AS [Principal],
  principalemail AS [Principal_email],
  schooladdress AS [School_address],
  schoolcity AS [School_city],
  schoolstate AS [School_state],
  schoolzip AS [School_zip],
  NULL AS [School_phone]
FROM
  gabby.powerschool.schools
WHERE
  /* filter out summer school and graduated students */
  state_excludefromreporting = 0
UNION ALL
SELECT
  CAST(0 AS VARCHAR(25)) AS [School_id],
  'District Office' AS [School_name],
  CAST(0 AS VARCHAR(25)) AS [School_number],
  NULL AS [State_id],
  'Kindergarten' AS [Low_grade],
  '12' AS [High_grade],
  'Ryan Hill' AS [Principal],
  'rhill@kippteamandfamily.org' AS [Principal_email],
  '60 Park Place, Suite 802' AS [School_address],
  'Newark' AS [School_city],
  'NJ' AS [School_state],
  '07102' AS [School_zip],
  NULL AS [School_phone]
