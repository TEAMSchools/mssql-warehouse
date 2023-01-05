WITH
  worker_custom_field_group AS (
    SELECT
      associate_oid,
      CAST(
        JSON_VALUE(worker_id, '$.idValue') AS NVARCHAR(16)
      ) AS worker_id,
      JSON_QUERY(
        custom_field_group,
        '$.stringFields'
      ) AS string_fields,
      JSON_QUERY(
        custom_field_group,
        '$.codeFields'
      ) AS code_fields,
      JSON_QUERY(
        custom_field_group,
        '$.dateFields'
      ) AS date_fields,
      JSON_QUERY(
        custom_field_group,
        '$.indicatorFields'
      ) AS indicator_fields,
      JSON_QUERY(
        custom_field_group,
        '$.numberFields'
      ) AS number_fields,
      JSON_QUERY(
        custom_field_group,
        '$.multiCodeFields'
      ) AS multi_code_fields
    FROM
      adp.workers
  ),
  worker_person_custom_field_group AS (
    SELECT
      associate_oid,
      CAST(
        JSON_VALUE(worker_id, '$.idValue') AS NVARCHAR(16)
      ) AS worker_id,
      JSON_QUERY(
        custom_field_group,
        '$.customFieldGroup.stringFields'
      ) AS string_fields,
      JSON_QUERY(
        person,
        '$.customFieldGroup.codeFields'
      ) AS code_fields,
      JSON_QUERY(
        person,
        '$.customFieldGroup.dateFields'
      ) AS date_fields,
      JSON_QUERY(
        person,
        '$.customFieldGroup.indicatorFields'
      ) AS indicator_fields,
      JSON_QUERY(
        person,
        '$.customFieldGroup.numberFields'
      ) AS number_fields,
      JSON_QUERY(
        person,
        '$.customFieldGroup.multiCodeFields'
      ) AS multi_code_fields
    FROM
      adp.workers
  ),
  string_fields AS (
    SELECT
      w.associate_oid,
      w.worker_id,
      'worker' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.stringValue') AS NVARCHAR(128)
      ) AS string_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_custom_field_group AS w
      CROSS APPLY OPENJSON (w.string_fields, '$') AS cfg
    WHERE
      w.string_fields != '{}'
    UNION ALL
    SELECT
      w.associate_oid,
      w.worker_id,
      'person' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.stringValue') AS NVARCHAR(128)
      ) AS string_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_person_custom_field_group AS w
      CROSS APPLY OPENJSON (w.string_fields, '$') AS cfg
    WHERE
      w.string_fields != '{}'
  ),
  code_fields AS (
    SELECT
      w.associate_oid,
      w.worker_id,
      'worker' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.codeValue') AS NVARCHAR(128)
      ) AS code_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_custom_field_group AS w
      CROSS APPLY OPENJSON (w.code_fields, '$') AS cfg
    WHERE
      w.code_fields != '{}'
    UNION ALL
    SELECT
      w.associate_oid,
      w.worker_id,
      'person' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.codeValue') AS NVARCHAR(128)
      ) AS code_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_person_custom_field_group AS w
      CROSS APPLY OPENJSON (w.code_fields, '$') AS cfg
    WHERE
      w.code_fields != '{}'
  ),
  date_fields AS (
    SELECT
      w.associate_oid,
      w.worker_id,
      'worker' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.dateValue') AS DATE
      ) AS date_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_custom_field_group AS w
      CROSS APPLY OPENJSON (w.date_fields, '$') AS cfg
    WHERE
      w.date_fields != '{}'
    UNION ALL
    SELECT
      w.associate_oid,
      w.worker_id,
      'person' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.dateValue') AS DATE
      ) AS date_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_person_custom_field_group AS w
      CROSS APPLY OPENJSON (w.date_fields, '$') AS cfg
    WHERE
      w.date_fields != '{}'
  ),
  indicator_fields AS (
    SELECT
      w.associate_oid,
      w.worker_id,
      'worker' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.indicatorValue') AS BIT
      ) AS indicator_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_custom_field_group AS w
      CROSS APPLY OPENJSON (w.indicator_fields, '$') AS cfg
    WHERE
      w.indicator_fields != '{}'
    UNION ALL
    SELECT
      w.associate_oid,
      w.worker_id,
      'person' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.indicatorValue') AS BIT
      ) AS indicator_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_person_custom_field_group AS w
      CROSS APPLY OPENJSON (w.indicator_fields, '$') AS cfg
    WHERE
      w.indicator_fields != '{}'
  ),
  number_fields AS (
    SELECT
      w.associate_oid,
      w.worker_id,
      'worker' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.numberValue') AS NVARCHAR(128)
      ) AS number_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_custom_field_group AS w
      CROSS APPLY OPENJSON (w.number_fields, '$') AS cfg
    WHERE
      w.number_fields != '{}'
    UNION ALL
    SELECT
      w.associate_oid,
      w.worker_id,
      'person' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      CAST(
        JSON_VALUE(cfg.[value], '$.numberValue') AS FLOAT
      ) AS number_value,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_person_custom_field_group AS w
      CROSS APPLY OPENJSON (w.number_fields, '$') AS cfg
    WHERE
      w.number_fields != '{}'
  ),
  multi_code_fields_codes AS (
    SELECT
      w.associate_oid,
      w.worker_id,
      'worker' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      JSON_QUERY(cfg.[value], '$.codes') AS codes,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_custom_field_group AS w
      CROSS APPLY OPENJSON (w.multi_code_fields, '$') AS cfg
    WHERE
      w.multi_code_fields != '{}'
    UNION ALL
    SELECT
      w.associate_oid,
      w.worker_id,
      'person' AS parent_object,
      CAST(
        JSON_VALUE(cfg.[value], '$.itemID') AS NVARCHAR(128)
      ) AS item_id,
      JSON_QUERY(cfg.[value], '$.codes') AS codes,
      JSON_QUERY(cfg.[value], '$.nameCode') AS name_code
    FROM
      worker_person_custom_field_group AS w
      CROSS APPLY OPENJSON (w.multi_code_fields, '$') AS cfg
    WHERE
      w.multi_code_fields != '{}'
  ),
  multi_code_fields AS (
    SELECT
      mcfc.associate_oid,
      mcfc.worker_id,
      mcfc.parent_object,
      mcfc.item_id,
      CAST(
        JSON_VALUE(mcfc.name_code, '$.codeValue') AS NVARCHAR(128)
      ) AS name_code_value,
      CAST(
        JSON_VALUE(mcfc.name_code, '$.shortName') AS NVARCHAR(128)
      ) AS name_code_short_name,
      CAST(
        JSON_VALUE(mcfc.name_code, '$.longName') AS NVARCHAR(128)
      ) AS name_code_long_name,
      CAST(
        JSON_VALUE(cfg.[value], '$.codeValue') AS NVARCHAR(128)
      ) AS code_value,
      CAST(
        JSON_VALUE(cfg.[value], '$.shortName') AS NVARCHAR(128)
      ) AS code_short_name,
      CAST(
        JSON_VALUE(cfg.[value], '$.longName') AS NVARCHAR(128)
      ) AS code_long_name
    FROM
      multi_code_fields_codes AS mcfc
      CROSS APPLY OPENJSON (mcfc.codes, '$') AS cfg
    WHERE
      mcfc.codes != '[]'
  )
SELECT
  associate_oid,
  worker_id,
  parent_object,
  'stringFields' AS custom_field_group,
  item_id,
  string_value,
  NULL AS code_value,
  NULL AS date_value,
  NULL AS indicator_value,
  CASE
    WHEN ISNUMERIC(string_value) = 1 THEN CAST(string_value AS FLOAT)
  END AS number_value,
  CAST(
    JSON_VALUE(name_code, '$.codeValue') AS NVARCHAR(128)
  ) AS name_code_value,
  CAST(
    JSON_VALUE(name_code, '$.shortName') AS NVARCHAR(128)
  ) AS name_code_short_name,
  CAST(
    JSON_VALUE(name_code, '$.longName') AS NVARCHAR(128)
  ) AS name_code_long_name
FROM
  string_fields
WHERE
  string_value IS NOT NULL
UNION ALL
SELECT
  associate_oid,
  worker_id,
  parent_object,
  'codeFields' AS custom_field_group,
  item_id,
  NULL AS string_value,
  code_value,
  NULL AS date_value,
  NULL AS indicator_value,
  CASE
    WHEN ISNUMERIC(code_value) = 1 THEN CAST(code_value AS FLOAT)
  END AS number_value,
  CAST(
    JSON_VALUE(name_code, '$.codeValue') AS NVARCHAR(128)
  ) AS name_code_value,
  CAST(
    JSON_VALUE(name_code, '$.shortName') AS NVARCHAR(128)
  ) AS name_code_short_name,
  CAST(
    JSON_VALUE(name_code, '$.longName') AS NVARCHAR(128)
  ) AS name_code_long_name
FROM
  code_fields
WHERE
  code_value IS NOT NULL
UNION ALL
SELECT
  associate_oid,
  worker_id,
  parent_object,
  'dateFields' AS custom_field_group,
  item_id,
  NULL AS string_value,
  NULL AS code_value,
  date_value,
  NULL AS indicator_value,
  NULL AS number_value,
  CAST(
    JSON_VALUE(name_code, '$.codeValue') AS NVARCHAR(128)
  ) AS name_code_value,
  CAST(
    JSON_VALUE(name_code, '$.shortName') AS NVARCHAR(128)
  ) AS name_code_short_name,
  CAST(
    JSON_VALUE(name_code, '$.longName') AS NVARCHAR(128)
  ) AS name_code_long_name
FROM
  date_fields
WHERE
  date_value IS NOT NULL
UNION ALL
SELECT
  associate_oid,
  worker_id,
  parent_object,
  'indicatorFields' AS custom_field_group,
  item_id,
  NULL AS string_value,
  NULL AS code_value,
  NULL AS date_value,
  indicator_value,
  NULL AS number_value,
  CAST(
    JSON_VALUE(name_code, '$.codeValue') AS NVARCHAR(128)
  ) AS name_code_value,
  CAST(
    JSON_VALUE(name_code, '$.shortName') AS NVARCHAR(128)
  ) AS name_code_short_name,
  CAST(
    JSON_VALUE(name_code, '$.longName') AS NVARCHAR(128)
  ) AS name_code_long_name
FROM
  indicator_fields
WHERE
  indicator_value IS NOT NULL
UNION ALL
SELECT
  associate_oid,
  worker_id,
  parent_object,
  'numberFields' AS custom_field_group,
  item_id,
  NULL AS string_value,
  NULL AS code_value,
  NULL AS date_value,
  NULL AS indicator_value,
  number_value,
  CAST(
    JSON_VALUE(name_code, '$.codeValue') AS NVARCHAR(128)
  ) AS name_code_value,
  CAST(
    JSON_VALUE(name_code, '$.shortName') AS NVARCHAR(128)
  ) AS name_code_short_name,
  CAST(
    JSON_VALUE(name_code, '$.longName') AS NVARCHAR(128)
  ) AS name_code_long_name
FROM
  number_fields
WHERE
  number_value IS NOT NULL
UNION ALL
SELECT
  associate_oid,
  worker_id,
  parent_object,
  'multiCodeFields' AS custom_field_group,
  item_id,
  NULL AS string_value,
  code_value,
  NULL AS date_value,
  NULL AS indicator_value,
  NULL AS number_value,
  name_code_value,
  name_code_short_name,
  name_code_long_name
FROM
  multi_code_fields
WHERE
  code_value IS NOT NULL
