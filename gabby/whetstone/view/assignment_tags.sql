CREATE OR ALTER VIEW
  whetstone.assignment_tags AS
SELECT
  wa._id AS assignment_id,
  wa.type AS assignment_type,
  CAST(
    JSON_VALUE(wt.[value], '$._id') AS VARCHAR(25)
  ) AS tag_id,
  CAST(
    JSON_VALUE(wt.[value], '$.name') AS VARCHAR(125)
  ) AS tag_name,
  CAST(
    JSON_VALUE(wt.[value], '$.url') AS VARCHAR(125)
  ) AS tag_url
FROM
  whetstone.stg_assignments AS wa
  CROSS APPLY OPENJSON (wa.tags, '$') AS wt
WHERE
  wa.tags != '[]'
