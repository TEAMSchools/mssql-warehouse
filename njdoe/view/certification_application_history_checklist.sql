USE gabby GO
CREATE OR ALTER VIEW
  njdoe.certification_application_history_checklist AS
SELECT
  ah.df_employee_number,
  ah.application_number,
  CAST(
    JSON_VALUE(ah.checklist, '$.filing_date') AS DATE
  ) AS application_filing_date,
  cl.task,
  CASE
    WHEN cl.comment <> '' THEN cl.comment
  END AS comment,
  cl.complete
FROM
  njdoe.certification_application_history_static AS ah
  CROSS APPLY OPENJSON (ah.checklist, '$.tasks')
WITH
  (
    task NVARCHAR(256),
    comment NVARCHAR(512),
    complete BIT
  ) AS cl
WHERE
  ah.checklist <> '[]'
