CREATE OR ALTER VIEW
  utilities.all_tables_columns AS
SELECT
  (
    DB_NAME()
    COLLATE LATIN1_GENERAL_BIN
  ) AS [db_name],
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
  sys.schemas AS s
  INNER JOIN sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  DB_NAME() AS [db_name],
  s.[name] AS [schema_name],
  t.[name] AS table_name,
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
  sys.schemas AS s
  INNER JOIN sys.objects AS t ON (
    s.[schema_id] = t.[schema_id]
    AND t.[type] IN ('U', 'V')
  )
  INNER JOIN sys.columns AS c ON (t.[object_id] = c.[object_id])
  INNER JOIN sys.types AS y ON (c.user_type_id = y.user_type_id)
WHERE
  (
    s.[schema_id] BETWEEN 5 AND 16383
  )
UNION ALL
SELECT
  [db_name],
  [schema_name],
  table_name,
  [type],
  column_id,
  column_name,
  column_max_length,
  column_type
FROM
  kippmiami.utilities.all_tables_columns
WHERE
  column_id > -1
  AND table_name NOT LIKE 'fivetran%'
  AND [schema_name] != 'fivetran_log'
UNION ALL
SELECT
  [db_name],
  [schema_name],
  table_name,
  [type],
  column_id,
  column_name,
  column_max_length,
  column_type
FROM
  kippnewark.utilities.all_tables_columns
WHERE
  column_id > -1
  AND table_name NOT LIKE 'fivetran%'
  AND [schema_name] != 'fivetran_log'
UNION ALL
SELECT
  [db_name],
  [schema_name],
  table_name,
  [type],
  column_id,
  column_name,
  column_max_length,
  column_type
FROM
  kippcamden.utilities.all_tables_columns
WHERE
  column_id > -1
  AND table_name NOT LIKE 'fivetran%'
  AND [schema_name] != 'fivetran_log'
UNION ALL
SELECT
  [db_name],
  [schema_name],
  table_name,
  [type],
  column_id,
  column_name,
  column_max_length,
  column_type
FROM
  kipptaf.utilities.all_tables_columns
WHERE
  column_id > -1
  AND table_name NOT LIKE 'fivetran%'
  AND [schema_name] != 'fivetran_log'
