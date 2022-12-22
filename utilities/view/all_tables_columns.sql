CREATE OR ALTER VIEW
  utilities.all_tables_columns AS
SELECT
  'gabby' AS [db_name],
  (
    s.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS [schema_name],
  (
    t.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  t.[type],
  -1 AS column_id,
  NULL AS column_name,
  NULL AS column_max_length,
  NULL AS column_type
FROM
  gabby.sys.schemas AS s
  INNER JOIN gabby.sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'gabby' AS [db_name],
  (
    s.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS [schema_name],
  (
    t.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  t.[type],
  c.column_id,
  (
    c.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_name,
  c.max_length AS column_max_length,
  (
    y.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_type
FROM
  gabby.sys.schemas AS s
  INNER JOIN gabby.sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
  INNER JOIN gabby.sys.columns AS c ON (t.[object_id] = c.[object_id])
  INNER JOIN gabby.sys.types AS y ON (c.user_type_id = y.user_type_id)
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kippnewark' AS [db_name],
  s.[name] AS [schema_name],
  t.[name] AS table_name,
  t.[type],
  -1 AS column_id,
  NULL AS column_name,
  NULL AS column_max_length,
  NULL AS column_type
FROM
  [kippnewark].sys.schemas AS s
  INNER JOIN [kippnewark].sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kippnewark' AS [db_name],
  s.[name] AS [schema_name],
  t.[name] AS table_name,
  t.[type],
  c.column_id,
  c.[name] AS column_name,
  c.max_length AS column_max_length,
  y.[name] AS column_type
FROM
  [kippnewark].sys.schemas AS s
  INNER JOIN [kippnewark].sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
  INNER JOIN [kippnewark].sys.columns AS c ON (t.[object_id] = c.[object_id])
  INNER JOIN kippnewark.sys.types AS y ON (c.user_type_id = y.user_type_id)
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kippcamden' AS [db_name],
  s.[name] AS [schema_name],
  t.[name] AS table_name,
  t.[type],
  -1 AS column_id,
  NULL AS column_name,
  NULL AS column_max_length,
  NULL AS column_type
FROM
  [kippcamden].sys.schemas AS s
  INNER JOIN [kippcamden].sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kippcamden' AS [db_name],
  s.[name] AS [schema_name],
  t.[name] AS table_name,
  t.[type],
  c.column_id,
  c.[name] AS column_name,
  c.max_length AS column_max_length,
  y.[name] AS column_type
FROM
  [kippcamden].sys.schemas AS s
  INNER JOIN [kippcamden].sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
  INNER JOIN [kippcamden].sys.columns AS c ON (t.[object_id] = c.[object_id])
  INNER JOIN kippcamden.sys.types AS y ON (c.user_type_id = y.user_type_id)
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kippmiami' AS [db_name],
  s.[name] AS [schema_name],
  t.[name] AS table_name,
  t.[type],
  -1 AS column_id,
  NULL AS column_name,
  NULL AS column_max_length,
  NULL AS column_type
FROM
  [kippmiami].sys.schemas AS s
  INNER JOIN [kippmiami].sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kippmiami' AS [db_name],
  s.[name] AS [schema_name],
  t.[name] AS table_name,
  t.[type],
  c.column_id,
  c.[name] AS column_name,
  c.max_length AS column_max_length,
  y.[name] AS column_type
FROM
  [kippmiami].sys.schemas AS s
  INNER JOIN [kippmiami].sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
  INNER JOIN [kippmiami].sys.columns AS c ON (t.[object_id] = c.[object_id])
  INNER JOIN kippmiami.sys.types AS y ON (c.user_type_id = y.user_type_id)
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kipptaf' AS [db_name],
  (
    s.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS [schema_name],
  (
    t.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  t.[type],
  -1 AS column_id,
  NULL AS column_name,
  NULL AS column_max_length,
  NULL AS column_type
FROM
  kipptaf.sys.schemas AS s
  INNER JOIN kipptaf.sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  'kipptaf' AS [db_name],
  (
    s.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS [schema_name],
  (
    t.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  t.[type],
  c.column_id,
  (
    c.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_name,
  c.max_length AS column_max_length,
  (
    y.[name]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_type
FROM
  kipptaf.sys.schemas AS s
  INNER JOIN kipptaf.sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
  INNER JOIN kipptaf.sys.columns AS c ON (t.[object_id] = c.[object_id])
  INNER JOIN kipptaf.sys.types AS y ON (c.user_type_id = y.user_type_id)
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
