CREATE OR ALTER VIEW
  extracts.idauto_staff_roster AS
SELECT
  associate_id AS [Associate ID],
  employee_number AS [Position ID],
  preferred_first_name AS [First Name],
  preferred_last_name AS [Last Name],
  business_unit AS [Company Code],
  [location] AS [Location Description],
  home_department AS [Business Unit Description],
  home_department AS [Home Department Description],
  job_title AS [Job Title Description],
  NULL AS [Preferred Name],
  CAST(
    manager_employee_number AS VARCHAR
  ) AS [Business Unit Code],
  CONVERT(VARCHAR, rehire_date, 101) AS [Rehire Date],
  CONVERT(VARCHAR, termination_date, 101) AS [Termination Date],
  CONVERT(VARCHAR, birth_date, 101) AS [Birth Date],
  CASE
    WHEN position_status = 'Prestart' THEN 'Active'
    ELSE position_status
  END AS [Position Status]
FROM
  people.staff_roster
WHERE
  COALESCE(rehire_date, original_hire_date) <= DATEADD(DAY, 10, CURRENT_TIMESTAMP)
  AND business_unit IS NOT NULL
  AND [location] IS NOT NULL
