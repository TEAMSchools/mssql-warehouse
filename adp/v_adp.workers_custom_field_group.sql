USE gabby
GO

CREATE OR ALTER VIEW adp.workers_custom_field_group AS

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'worker' AS parent_object
      ,'stringFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.stringValue AS string_value
      ,NULL AS code_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.stringValue) = 1 THEN CAST(cfg.stringValue AS INT) END AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.stringValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.custom_field_group, '$.stringFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,stringValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.custom_field_group, '$.stringFields') <> '{}'
  AND cfg.stringValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'worker' AS parent_object
      ,'codeFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.codeValue AS string_value
      ,cfg.codeValue AS code_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.codeValue) = 1 THEN CAST(cfg.codeValue AS INT) END AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.codeValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.custom_field_group, '$.codeFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,codeValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.custom_field_group, '$.codeFields') <> '{}'
  AND cfg.codeValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'worker' AS parent_object
      ,'dateFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.dateValue AS string_value
      ,NULL AS code_value
      ,CAST(cfg.dateValue AS DATE) AS date_value
      ,NULL AS bit_value
      ,NULL AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.dateValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.custom_field_group, '$.dateFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,dateValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.custom_field_group, '$.dateFields') <> '{}'
  AND cfg.dateValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'worker' AS parent_object
      ,'indicatorFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.indicatorValue AS string_value
      ,NULL AS code_value
      ,NULL AS date_value
      ,CAST(cfg.indicatorValue AS BIT) AS bit_value
      ,NULL AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.indicatorValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.custom_field_group, '$.indicatorFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,indicatorValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.custom_field_group, '$.indicatorFields') <> '{}'
  AND cfg.indicatorValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'person' AS parent_object
      ,'stringFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.stringValue AS string_value
      ,NULL AS code_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.stringValue) = 1 THEN CAST(cfg.stringValue AS INT) END AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.stringValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.person, '$.customFieldGroup.stringFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,stringValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.person, '$.customFieldGroup.stringFields') <> '{}'
  AND cfg.stringValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'person' AS parent_object
      ,'codeFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.codeValue AS string_value
      ,cfg.codeValue AS code_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.codeValue) = 1 THEN CAST(cfg.codeValue AS INT) END AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.codeValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.person, '$.customFieldGroup.codeFields')
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,codeValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.person, '$.customFieldGroup.codeFields') <> '{}'
  AND cfg.codeValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'person' AS parent_object
      ,'dateFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.dateValue AS string_value
      ,NULL AS code_value
      ,CAST(cfg.dateValue AS DATE) AS date_value
      ,NULL AS bit_value
      ,NULL AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.dateValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.person, '$.customFieldGroup.dateFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,dateValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.person, '$.customFieldGroup.dateFields') <> '{}'
  AND cfg.dateValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'person' AS parent_object
      ,'indicatorFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.indicatorValue AS string_value
      ,NULL AS code_value
      ,NULL AS date_value
      ,CAST(cfg.indicatorValue AS BIT) AS bit_value
      ,NULL AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.indicatorValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.person, '$.customFieldGroup.indicatorFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,indicatorValue NVARCHAR(128)
 ) cfg
WHERE JSON_QUERY(w.person, '$.customFieldGroup.indicatorFields') <> '{}'
  AND cfg.indicatorValue IS NOT NULL

UNION ALL

SELECT w.associate_oid
      ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id
      ,'person' AS parent_object
      ,'numberFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.numberValue AS string_value
      ,NULL AS code_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.numberValue) = 1 THEN CAST(cfg.numberValue AS FLOAT) END AS numeric_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
      ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
      ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
      ,cfg.numberValue AS item_value
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.person, '$.customFieldGroup.numberFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,numberValue NVARCHAR(128)
 ) cfg
WHERE cfg.numberValue IS NOT NULL

UNION ALL

SELECT sub.associate_oid
      ,sub.worker_id
      ,'person' AS parent_object
      ,'multiCodeFields' AS custom_field_group

      ,sub.item_id
      ,cfg.codeValue AS string_value
      ,cfg.codeValue AS code_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.codeValue) = 1 THEN CAST(cfg.codeValue AS INT) END AS numeric_value
      ,sub.name_code_value
      ,sub.name_code_short_name
      ,sub.name_code_long_name
      ,cfg.codeValue AS item_value
FROM
    (
     SELECT w.associate_oid
           ,CAST(JSON_VALUE(w.worker_id, '$.idValue') AS NVARCHAR(16)) AS worker_id

           ,cfg.itemID AS item_id
           ,cfg.codes
           ,CAST(JSON_VALUE(cfg.nameCode, '$.codeValue') AS NVARCHAR(128)) AS name_code_value
           ,CAST(JSON_VALUE(cfg.nameCode, '$.shortName') AS NVARCHAR(128)) AS name_code_short_name
           ,CAST(JSON_VALUE(cfg.nameCode, '$.longName') AS NVARCHAR(128)) AS name_code_long_name
     FROM gabby.adp.workers w
     CROSS APPLY OPENJSON(w.person, '$.customFieldGroup.multiCodeFields') 
       WITH(
         itemID NVARCHAR(128)
        ,nameCode NVARCHAR(MAX) AS JSON
        ,codes NVARCHAR(MAX) AS JSON
      ) cfg
     WHERE JSON_QUERY(w.person, '$.customFieldGroup.multiCodeFields') <> '{}'
    ) sub
CROSS APPLY OPENJSON(sub.codes, '$') 
  WITH(
    codeValue NVARCHAR(128)
   ,longName NVARCHAR(MAX)
   ,shortName NVARCHAR(MAX)
 ) cfg
WHERE sub.codes <> '[]'
