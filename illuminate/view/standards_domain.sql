CREATE OR ALTER VIEW
  illuminate_standards.standards_domain AS
WITH
  standards_ladder AS (
    SELECT
      standard_id AS domain_standard_id,
      custom_code AS domain_custom_code,
      CAST([description] AS VARCHAR(2000)) AS domain_description,
      [label] AS domain_label,
      [level] AS domain_level,
      standard_id,
      custom_code,
      parent_standard_id,
      [level]
    FROM
      gabby.illuminate_standards.standards
    UNION ALL
    SELECT
      s3.domain_standard_id,
      s3.domain_custom_code,
      s3.domain_description,
      s3.domain_label,
      s3.domain_level,
      s2.standard_id,
      s2.custom_code,
      s2.parent_standard_id,
      s2.[level]
    FROM
      gabby.illuminate_standards.standards AS s2
      INNER JOIN standards_ladder AS s3 ON (
        s2.parent_standard_id = s3.standard_id
      )
  )
SELECT
  domain_standard_id,
  domain_custom_code,
  domain_description,
  domain_label,
  domain_level,
  standard_id,
  custom_code,
  parent_standard_id,
  [level]
FROM
  standards_ladder
