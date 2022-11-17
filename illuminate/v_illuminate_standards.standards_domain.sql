USE gabby
GO

CREATE OR ALTER VIEW illuminate_standards.standards_domain AS

WITH standards_ladder AS (
  SELECT s1.standard_id AS domain_standard_id
        ,s1.custom_code AS domain_custom_code
        ,CAST(s1.[description] AS VARCHAR(2000)) AS domain_description
        ,s1.[label] AS domain_label
        ,s1.[level] AS domain_level
        ,s1.standard_id
        ,s1.custom_code
        ,s1.parent_standard_id
        ,s1.[level]
  FROM gabby.illuminate_standards.standards s1

  UNION ALL

  SELECT s3.domain_standard_id
        ,s3.domain_custom_code
        ,s3.domain_description
        ,s3.domain_label
        ,s3.domain_level

        ,s2.standard_id
        ,s2.custom_code
        ,s2.parent_standard_id
        ,s2.[level]
  FROM gabby.illuminate_standards.standards s2
  JOIN standards_ladder s3
    ON s2.parent_standard_id = s3.standard_id
)

SELECT standards_ladder.domain_standard_id
      ,standards_ladder.domain_custom_code
      ,standards_ladder.domain_description
      ,standards_ladder.domain_label
      ,standards_ladder.domain_level
      ,standards_ladder.standard_id
      ,standards_ladder.custom_code
      ,standards_ladder.parent_standard_id
      ,standards_ladder.[level]
FROM standards_ladder
