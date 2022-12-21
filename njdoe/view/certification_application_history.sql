CREATE OR ALTER VIEW
  njdoe.certification_application_history AS
WITH
  ah AS (
    SELECT
      cc.df_employee_number,
      CAST(
        JSON_VALUE(
          ah.[value],
          '$.application_number'
        ) AS INT
      ) AS application_number,
      CAST(
        JSON_VALUE(ah.[value], '$.date_received') AS DATE
      ) AS date_received,
      CAST(
        JSON_VALUE(ah.[value], '$.endorsement') AS NVARCHAR(256)
      ) AS endorsement,
      CAST(
        JSON_VALUE(ah.[value], '$.certificate_type') AS NVARCHAR(256)
      ) AS certificate_type,
      CAST(
        JSON_VALUE(ah.[value], '$.request_type') AS NVARCHAR(256)
      ) AS request_type,
      CAST(
        JSON_VALUE(ah.[value], '$.status') AS NVARCHAR(256)
      ) AS [status],
      JSON_QUERY(ah.[value], '$.checklist') AS checklist
    FROM
      gabby.njdoe.certification_check AS cc
      CROSS APPLY OPENJSON (cc.application_history, '$') AS ah
    WHERE
      cc.application_history != '[]'
  )
SELECT
  df_employee_number,
  NULL AS application_history_json,
  application_number,
  date_received,
  endorsement,
  CASE
    WHEN certificate_type != '' THEN certificate_type
  END AS certificate_type,
  CASE
    WHEN request_type != '' THEN request_type
  END AS request_type,
  CASE
    WHEN [status] != '' THEN [status]
  END AS [status],
  checklist
FROM
  ah
