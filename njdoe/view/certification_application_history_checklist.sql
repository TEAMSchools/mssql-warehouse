WITH
  checklist AS (
    SELECT
      ah.df_employee_number,
      ah.application_number,
      CAST(
        JSON_VALUE(ah.checklist, '$.filing_date') AS DATE
      ) AS application_filing_date,
      CAST(
        JSON_VALUE(cl.[value], '$.task') AS NVARCHAR(256)
      ) AS task,
      CAST(
        JSON_VALUE(cl.[value], '$.comment') AS NVARCHAR(512)
      ) AS comment,
      CAST(
        JSON_VALUE(cl.[value], '$.complete') AS BIT
      ) AS complete
    FROM
      njdoe.certification_application_history_static AS ah
      CROSS APPLY OPENJSON (ah.checklist, '$.tasks') AS cl
    WHERE
      ah.checklist != '[]'
  )
SELECT
  df_employee_number,
  application_number,
  application_filing_date,
  task,
  complete,
  CASE
    WHEN comment != '' THEN comment
  END AS comment
FROM
  checklist
