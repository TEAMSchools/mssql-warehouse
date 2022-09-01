USE gabby
GO

CREATE OR ALTER VIEW extracts.idauto_staff_roster AS

SELECT df.associate_id AS [Associate ID]
      ,df.employee_number AS [Position ID]
      ,df.preferred_first_name AS [First Name]
      ,df.preferred_last_name AS [Last Name]
      ,df.business_unit AS [Company Code]
      ,df.[location] AS [Location Description]
      ,df.home_department AS [Business Unit Description]
      ,df.home_department AS [Home Department Description]
      ,df.job_title AS [Job Title Description]
      ,CAST(df.manager_employee_number AS VARCHAR) AS [Business Unit Code]
      ,CAST(df.rehire_date, 101 AS VARCHAR) AS [Rehire Date]
      ,CAST(df.termination_date, 101 AS VARCHAR) AS [Termination Date]
      ,CAST(df.birth_date, 101 AS VARCHAR) AS [Birth Date]
      ,CASE WHEN df.position_status = 'Prestart' THEN 'Active' ELSE df.position_status END AS [Position Status]
      ,NULL AS [Preferred Name]
FROM gabby.people.staff_roster df
WHERE COALESCE(df.rehire_date, df.original_hire_date) <= DATEADD(DAY, 10, CURRENT_TIMESTAMP)
