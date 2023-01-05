CREATE OR ALTER VIEW
  njdoe.certification_certificate_history AS
WITH
  ch AS (
    SELECT
      cc.df_employee_number,
      CAST(
        JSON_VALUE(ch.[value], '$.seq_number') AS INT
      ) AS seq_number,
      CAST(
        JSON_VALUE(ch.[value], '$.certificate_type') AS NVARCHAR(256)
      ) AS certificate_type,
      CAST(
        JSON_VALUE(ch.[value], '$.endorsement') AS NVARCHAR(256)
      ) AS endorsement,
      CAST(
        JSON_VALUE(ch.[value], '$.county_code') AS NVARCHAR(256)
      ) AS county_code,
      CAST(
        JSON_VALUE(ch.[value], '$.district_code') AS NVARCHAR(256)
      ) AS district_code,
      CAST(
        JSON_VALUE(ch.[value], '$.basis_code') AS NVARCHAR(256)
      ) AS basis_code,
      CAST(
        JSON_VALUE(
          ch.[value],
          '$.month_year_issued'
        ) AS NVARCHAR(256)
      ) AS month_year_issued,
      CAST(
        JSON_VALUE(
          ch.[value],
          '$.month_year_expiration'
        ) AS NVARCHAR(256)
      ) AS month_year_expiration,
      CAST(
        JSON_VALUE(ch.[value], '$.certificate_id') AS NVARCHAR(256)
      ) AS certificate_id
    FROM
      njdoe.certification_check AS cc
      CROSS APPLY OPENJSON (cc.certificate_history, '$') AS ch
    WHERE
      cc.certificate_history != '[]'
  )
SELECT
  df_employee_number,
  seq_number,
  CASE
    WHEN certificate_id != '' THEN certificate_id
  END AS certificate_id,
  LTRIM(
    RTRIM(
      LEFT(
        utilities.STRIP_CHARACTERS (certificate_type, '^A-Z -'),
        28
      )
    )
  ) AS certificate_type,
  CASE
    WHEN CHARINDEX(
      'Charter School Only',
      certificate_type
    ) > 0 THEN 1
    ELSE 0
  END AS is_charter_school_only,
  endorsement,
  county_code,
  basis_code,
  CASE
    WHEN district_code != '' THEN district_code
  END AS district_code,
  CASE
    WHEN month_year_issued != '' THEN month_year_issued
  END AS month_year_issued,
  CASE
    WHEN month_year_issued != '' THEN DATEFROMPARTS(
      RIGHT(month_year_issued, 4),
      LEFT(month_year_issued, 2),
      1
    )
  END AS issued_date,
  CASE
    WHEN month_year_expiration != '' THEN month_year_expiration
  END AS month_year_expiration,
  CASE
    WHEN month_year_expiration = '' THEN NULL
    ELSE DATEADD(
      DAY,
      -1,
      DATEADD(
        MONTH,
        1,
        DATEFROMPARTS(
          RIGHT(month_year_expiration, 4),
          LEFT(month_year_expiration, 2),
          1
        )
      )
    )
  END AS expiration_date
FROM
  ch
