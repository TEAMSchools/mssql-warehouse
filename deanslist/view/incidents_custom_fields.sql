CREATE OR ALTER VIEW
  deanslist.incidents_custom_fields AS
SELECT
  dli.incident_id,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.CustomFieldID'
    ) AS BIGINT
  ) AS custom_field_id,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.FieldCategory'
    ) AS NVARCHAR(8)
  ) AS field_category,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.FieldKey'
    ) AS NVARCHAR(16)
  ) AS field_key,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.FieldName'
    ) AS NVARCHAR(64)
  ) AS field_name,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.FieldType'
    ) AS NVARCHAR(8)
  ) AS field_type,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.InputHTML'
    ) AS NVARCHAR(8)
  ) AS input_html,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.InputName'
    ) AS NVARCHAR(16)
  ) AS input_name,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.IsFrontEnd'
    ) AS NVARCHAR(1)
  ) AS is_front_end,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.IsRequired'
    ) AS NVARCHAR(1)
  ) AS is_required,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.LabelHTML'
    ) AS NVARCHAR(8)
  ) AS label_html,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.NumValue'
    ) AS FLOAT
  ) AS num_value,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.Options'
    ) AS NVARCHAR(8)
  ) AS options,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.SourceID'
    ) AS BIGINT
  ) AS source_id,
  CAST(
    JSON_VALUE(
      cf.[value],
      '$.SourceType'
    ) AS NVARCHAR(8)
  ) AS source_type,
  CASE
    WHEN JSON_VALUE(
      cf.[value],
      '$.StringValue'
    ) != '' THEN CAST(
      JSON_VALUE(
        cf.[value],
        '$.StringValue'
      ) AS NVARCHAR(MAX)
    )
  END AS string_value,
  CASE
    WHEN JSON_VALUE(cf.[value], '$.Value') != '' THEN CAST(
      JSON_VALUE(cf.[value], '$.Value') AS NVARCHAR(MAX)
    )
  END AS [value]
FROM
  deanslist.incidents AS dli
  CROSS APPLY OPENJSON (
    dli.custom_fields,
    '$'
  ) AS cf
WHERE
  dli.custom_fields != '[]'
