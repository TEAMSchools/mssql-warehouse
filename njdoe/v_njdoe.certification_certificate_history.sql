USE gabby GO
CREATE OR ALTER VIEW
  njdoe.certification_certificate_history AS
SELECT
  cc.df_employee_number,
  ch.seq_number,
  CASE
    WHEN ch.certificate_id <> '' THEN ch.certificate_id
  END AS certificate_id,
  LTRIM(RTRIM(LEFT(gabby.utilities.STRIP_CHARACTERS (ch.certificate_type, '^A-Z -'), 28))) AS certificate_type,
  CASE
    WHEN CHARINDEX('Charter School Only', ch.certificate_type) > 0 THEN 1
    ELSE 0
  END AS is_charter_school_only,
  ch.endorsement,
  ch.county_code,
  ch.basis_code,
  CASE
    WHEN ch.district_code <> '' THEN ch.district_code
  END AS district_code,
  CASE
    WHEN ch.month_year_issued <> '' THEN ch.month_year_issued
  END AS month_year_issued,
  CASE
    WHEN ch.month_year_issued <> '' THEN DATEFROMPARTS(
      CAST(RIGHT(ch.month_year_issued, 4)),
      CONVERT(INT, LEFT(ch.month_year_issued, 2)),
      1 AS INT
    )
  END AS issued_date,
  CASE
    WHEN ch.month_year_expiration <> '' THEN ch.month_year_expiration
  END AS month_year_expiration,
  CASE
    WHEN ch.month_year_expiration = '' THEN NULL
    ELSE DATEADD(
      DAY,
      -1,
      DATEADD(
        MONTH,
        1,
        DATEFROMPARTS(
          CAST(RIGHT(ch.month_year_expiration, 4)),
          CONVERT(INT, LEFT(ch.month_year_expiration, 2)),
          1
        )
      ) AS INT
    )
  END AS expiration_date
FROM
  gabby.njdoe.certification_check cc
  CROSS APPLY OPENJSON (cc.certificate_history, '$')
WITH
  (
    seq_number INT,
    certificate_type NVARCHAR(256),
    endorsement NVARCHAR(256),
    county_code NVARCHAR(256),
    district_code NVARCHAR(256),
    basis_code NVARCHAR(256),
    month_year_issued NVARCHAR(256),
    month_year_expiration NVARCHAR(256),
    certificate_id NVARCHAR(256)
  ) AS ch
WHERE
  cc.certificate_history <> '[]'
