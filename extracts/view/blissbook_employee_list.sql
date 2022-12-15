USE gabby GO
CREATE OR ALTER VIEW
  extracts.blissbook_employee_list AS
SELECT
  df.df_employee_number AS [Employee ID],
  df.mail AS [Email Address],
  CONCAT(
    df.preferred_first_name,
    ' ',
    df.preferred_last_name
  ) AS [Name],
  COALESCE(df.rehire_date, df.original_hire_date) AS [Latest Hire Date],
  df.legal_entity_name AS [Groups]
FROM
  gabby.people.staff_crosswalk_static AS df
WHERE
  df.[status] <> 'TERMINATED'
  AND df.mail IS NOT NULL
