SELECT
  SCHEMA_NAME(t.schema_id) AS [schema_name],
  t.name AS table_name,
  ind.name AS index_name,
  ind.type_desc,
  ind.is_unique,
  ind.is_primary_key,
  col.name AS column_name,
  ic.key_ordinal,
  ic.is_included_column
FROM
  sys.indexes AS ind
  INNER JOIN sys.index_columns AS ic ON (
    ind.object_id = ic.object_id
    AND ind.index_id = ic.index_id
  )
  INNER JOIN sys.columns AS col ON (
    ic.object_id = col.object_id
    AND ic.column_id = col.column_id
  )
  INNER JOIN sys.tables AS t ON (ind.object_id = t.object_id)
WHERE
  t.is_ms_shipped = 0
ORDER BY
  t.name,
  ind.name,
  ind.index_id,
  ic.is_included_column,
  ic.key_ordinal;
