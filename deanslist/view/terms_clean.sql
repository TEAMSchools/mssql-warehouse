CREATE OR ALTER VIEW
  deanslist.terms_clean AS
SELECT
  term_id,
  academic_year_id,
  academic_year_name,
  school_id,
  term_type_id,
  term_type,
  term_name,
  integration_id,
  secondary_integration_id,
  grade_key,
  stored_grades,
  CAST(
    JSON_VALUE(
      [start_date],
      '$.date'
    ) AS DATE
  ) AS [start_date],
  CAST(
    JSON_VALUE(end_date, '$.date') AS DATE
  ) AS end_date
FROM
  deanslist.terms
