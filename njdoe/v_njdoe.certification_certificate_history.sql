USE gabby
GO

CREATE OR ALTER VIEW njdoe.certification_certificate_history AS

SELECT cc.df_employee_number

      ,ch.seq_number
      ,CASE WHEN ch.certificate_id <> '' THEN ch.certificate_id END AS certificate_id
      ,LTRIM(RTRIM(LEFT(gabby.utilities.STRIP_CHARACTERS(ch.certificate_type, '^A-Z -'), 28))) AS certificate_type
      ,CASE WHEN CHARINDEX('Charter School Only', ch.certificate_type) > 0 THEN 1 ELSE 0 END AS is_charter_school_only
      ,ch.endorsement
      ,ch.county_code
      ,ch.basis_code
      ,CASE WHEN ch.district_code <> '' THEN ch.district_code END AS district_code
      ,CASE WHEN ch.month_year_issued <> '' THEN ch.month_year_issued END AS month_year_issued
      ,CASE WHEN ch.month_year_issued <> '' THEN DATEFROMPARTS(CONVERT(INT, RIGHT(ch.month_year_issued, 4)), CONVERT(INT, LEFT(ch.month_year_issued, 2)), 1) END AS issued_date
      ,CASE WHEN ch.month_year_expiration <> '' THEN ch.month_year_expiration END AS month_year_expiration
      ,CASE WHEN ch.month_year_expiration <> '' THEN DATEFROMPARTS(CONVERT(INT, RIGHT(ch.month_year_expiration, 4)), CONVERT(INT, LEFT(ch.month_year_expiration, 2)), 1) END AS expiration_date
FROM gabby.njdoe.certification_check_clean cc
CROSS APPLY OPENJSON(cc.certificate_history, '$')
  WITH (
    seq_number INT,
    certificate_type VARCHAR(250),
    endorsement VARCHAR(125),
    county_code VARCHAR(125),
    district_code VARCHAR(125),
    basis_code VARCHAR(125),
    month_year_issued VARCHAR(25),
    month_year_expiration VARCHAR(25),
    certificate_id VARCHAR(25)
   ) AS ch
WHERE cc.certificate_history <> '[]'
