USE gabby
GO

CREATE OR ALTER VIEW utilities.all_tables_columns AS

SELECT 'gabby' AS db_name
      ,s.name COLLATE Latin1_General_BIN AS schema_name
      ,t.name COLLATE Latin1_General_BIN AS table_name
      ,t.type
      ,-1 AS column_id
      ,NULL AS column_name
      ,NULL AS column_type
FROM gabby.sys.schemas AS s
INNER JOIN gabby.sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
WHERE s.schema_id BETWEEN 5 AND 16383
UNION ALL
SELECT 'gabby' AS db_name
      ,s.name COLLATE Latin1_General_BIN AS schema_name
      ,t.name COLLATE Latin1_General_BIN AS table_name
      ,t.type
      ,c.column_id
      ,c.name COLLATE Latin1_General_BIN AS column_name
      ,y.name COLLATE Latin1_General_BIN AS column_type
FROM gabby.sys.schemas AS s
INNER JOIN gabby.sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
INNER JOIN gabby.sys.columns c
   ON t.object_id = c.object_id
INNER JOIN gabby.sys.types y
   ON c.user_type_id = y.user_type_id
WHERE s.schema_id BETWEEN 5 AND 16383

UNION ALL

SELECT 'kippnewark' AS db_name
      ,s.name AS schema_name
      ,t.name AS table_name
      ,t.type
      ,-1 AS column_id
      ,NULL AS column_name
      ,NULL AS column_type
FROM [kippnewark].sys.schemas AS s
INNER JOIN [kippnewark].sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
WHERE s.schema_id BETWEEN 5 AND 16383
UNION ALL
SELECT 'kippnewark' AS db_name
      ,s.name AS schema_name
      ,t.name AS table_name
      ,t.type
      ,c.column_id
      ,c.name AS column_name
      ,y.name AS column_type
FROM [kippnewark].sys.schemas AS s
INNER JOIN [kippnewark].sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
INNER JOIN [kippnewark].sys.columns c
   ON t.object_id = c.object_id
INNER JOIN kippnewark.sys.types y
   ON c.user_type_id = y.user_type_id
WHERE s.schema_id BETWEEN 5 AND 16383

UNION ALL

SELECT 'kippcamden' AS db_name
      ,s.name AS schema_name
      ,t.name AS table_name
      ,t.type
      ,-1 AS column_id
      ,NULL AS column_name
      ,NULL AS column_type
FROM [kippcamden].sys.schemas AS s
INNER JOIN [kippcamden].sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
WHERE s.schema_id BETWEEN 5 AND 16383
UNION ALL
SELECT 'kippcamden' AS db_name
      ,s.name AS schema_name
      ,t.name AS table_name
      ,t.type
      ,c.column_id
      ,c.name AS column_name
      ,y.name AS column_type
FROM [kippcamden].sys.schemas AS s
INNER JOIN [kippcamden].sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
INNER JOIN [kippcamden].sys.columns c
   ON t.object_id = c.object_id
INNER JOIN kippcamden.sys.types y
   ON c.user_type_id = y.user_type_id
WHERE s.schema_id BETWEEN 5 AND 16383

UNION ALL

SELECT 'kippmiami' AS db_name
      ,s.name AS schema_name
      ,t.name AS table_name
      ,t.type
      ,-1 AS column_id
      ,NULL AS column_name
      ,NULL AS column_type
FROM [kippmiami].sys.schemas AS s
INNER JOIN [kippmiami].sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
WHERE s.schema_id BETWEEN 5 AND 16383
UNION ALL
SELECT 'kippmiami' AS db_name
      ,s.name AS schema_name
      ,t.name AS table_name
      ,t.type
      ,c.column_id
      ,c.name AS column_name
      ,y.name AS column_type
FROM [kippmiami].sys.schemas AS s
INNER JOIN [kippmiami].sys.objects AS t
   ON s.[schema_id] = t.[schema_id]
  AND t.type IN ('U', 'V')
INNER JOIN [kippmiami].sys.columns c
   ON t.object_id = c.object_id
INNER JOIN kippmiami.sys.types y
   ON c.user_type_id = y.user_type_id
WHERE s.schema_id BETWEEN 5 AND 16383