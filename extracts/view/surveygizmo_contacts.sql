USE gabby GO
CREATE OR ALTER VIEW
  extracts.alchemer_contacts AS
SELECT
  LOWER(mail) AS [Email],
  NULL AS [Phone (Mobile)],
  preferred_first_name AS [First Name],
  preferred_last_name AS [Last Name],
  legal_entity_name AS [Organization Name],
  primary_site AS [Division],
  primary_on_site_department AS [Department],
  NULL AS [Team],
  NULL AS [Group],
  NULL AS [Role],
  primary_job AS [Job Title],
  NULL AS [Website],
  NULL AS [Address],
  NULL AS [Suite/Apt],
  NULL AS [City],
  NULL AS [State/Region],
  NULL AS [Country],
  NULL AS [Postal Code],
  NULL AS [Phone (Home)],
  NULL AS [Phone (Fax)],
  NULL AS [Phone (Work)],
  df_employee_number AS [Employee Number],
  [Status]
FROM
  gabby.people.staff_crosswalk_static
WHERE
  [status] != 'PRESTART'
