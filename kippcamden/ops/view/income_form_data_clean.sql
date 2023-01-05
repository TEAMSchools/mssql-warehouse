CREATE OR ALTER VIEW
  ops.income_form_data_clean AS
SELECT
  student_number,
  academic_year,
  CASE
    WHEN (
      [status] IS NULL
      OR [status] IN ('No Application', 'No')
    ) THEN 'No Application'
    WHEN [status] IN (
      'Application Received',
      'Jotform'
    ) THEN 'Application Received'
    WHEN [status] = 'Direct Certification' THEN 'Direct Certification'
    ELSE LEFT([status], 1) + ' - ' + 'Income Form'
  END AS lunch_app_status,
  CASE
    WHEN [status] IN (
      'No Application',
      'Application Received',
      'Jotform',
      'No'
    ) THEN NULL
    WHEN [status] = 'Direct Certification' THEN 'F'
    ELSE LEFT([status], 1)
  END AS lunch_status,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      academic_year
    ORDER BY
      _row DESC
  ) AS rn,
  DB_NAME() AS [db_name]
FROM
  gabby.ops.income_form_data
WHERE
  ISNUMERIC(student_number) = 1
