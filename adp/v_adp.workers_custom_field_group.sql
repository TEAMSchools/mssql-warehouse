USE gabby
GO

CREATE OR ALTER VIEW adp.workers_custom_field_group AS

SELECT w.associate_oid
      ,CONVERT(NVARCHAR(16), JSON_VALUE(w.worker_id, '$.idValue')) AS worker_id
      ,'worker' AS parent_object
      ,'stringFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.stringValue AS string_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.stringValue) = 1 THEN CONVERT(INT, cfg.stringValue) END AS numeric_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.codeValue')) AS code_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.shortName')) AS short_name
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
      ,CONVERT(NVARCHAR(16), JSON_VALUE(w.worker_id, '$.idValue')) AS worker_id
      ,'worker' AS parent_object
      ,'codeFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.codeValue AS string_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.codeValue) = 1 THEN CONVERT(INT, cfg.codeValue) END AS numeric_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.codeValue')) AS code_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.shortName')) AS short_name
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
      ,CONVERT(NVARCHAR(16), JSON_VALUE(w.worker_id, '$.idValue')) AS worker_id
      ,'worker' AS parent_object
      ,'dateFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.dateValue AS string_value
      ,CONVERT(DATE, cfg.dateValue) AS date_value
      ,NULL AS bit_value
      ,NULL AS numeric_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.codeValue')) AS code_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.shortName')) AS short_name
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
      ,CONVERT(NVARCHAR(16), JSON_VALUE(w.worker_id, '$.idValue')) AS worker_id
      ,'worker' AS parent_object
      ,'indicatorFields' AS custom_field_group

      ,cfg.itemID AS item_id
      ,cfg.indicatorValue AS string_value
      ,NULL AS date_value
      ,CONVERT(BIT, cfg.indicatorValue) AS bit_value
      ,NULL AS numeric_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.codeValue')) AS code_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.shortName')) AS short_name
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

SELECT sub.associate_oid
      ,sub.worker_id
      ,'person' AS parent_object
      ,'multiCodeFields' AS custom_field_group
      ,sub.item_id
      ,cfg.codeValue AS string_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.codeValue) = 1 THEN CONVERT(INT, cfg.codeValue) END AS numeric_value
      ,sub.code_value
      ,sub.short_name
FROM
    (
     SELECT w.associate_oid
           ,CONVERT(NVARCHAR(16), JSON_VALUE(w.worker_id, '$.idValue')) AS worker_id

           ,cfg.itemID AS item_id
           ,cfg.codes
           ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.codeValue')) AS code_value
           ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.shortName')) AS short_name
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

UNION ALL

SELECT w.associate_oid
      ,CONVERT(NVARCHAR(16), JSON_VALUE(w.worker_id, '$.idValue')) AS worker_id
      ,'person' AS parent_object
      ,'numberFields' AS custom_field_group
      ,cfg.itemID AS item_id
      ,cfg.numberValue AS string_value
      ,NULL AS date_value
      ,NULL AS bit_value
      ,CASE WHEN ISNUMERIC(cfg.numberValue) = 1 THEN CONVERT(FLOAT, cfg.numberValue) END AS numeric_value
      ,cfg.numberValue AS code_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(cfg.nameCode, '$.codeValue')) AS short_name

FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.person, '$.customFieldGroup.numberFields') 
  WITH(
    itemID NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
   ,numberValue NVARCHAR(128)
 ) cfg
WHERE cfg.numberValue IS NOT NULL
