SELECT
  DB_NAME() AS [db_name],
  OBJECT_SCHEMA_NAME(ix.[object_id]) AS [schema_name],
  OBJECT_NAME(ix.[object_id]) AS table_name,
  ix.[name] AS index_name,
  ISNULL(ixus.user_seeks, 0) + ISNULL(ixus.user_scans, 0) + ISNULL(ixus.user_lookups, 0) AS total_reads,
  ISNULL(ixus.user_updates, 0) AS total_writes,
  CASE
    WHEN (
      ISNULL(ixus.user_seeks, 0) + ISNULL(ixus.user_scans, 0) + ISNULL(ixus.user_lookups, 0) + ISNULL(ixus.user_updates, 0)
    ) = 0 THEN 0
    ELSE CAST(
      (
        ISNULL(ixus.user_seeks, 0) + ISNULL(ixus.user_scans, 0) + ISNULL(ixus.user_lookups, 0) AS FLOAT
      ) / CAST(
        (
          ISNULL(ixus.user_seeks, 0) + ISNULL(ixus.user_scans, 0) + ISNULL(ixus.user_lookups, 0) + ISNULL(ixus.user_updates, 0)
        )
      ) AS FLOAT
    )
  END AS pct_reads,
  (
    SELECT
      MAX(dates.d)
    FROM
      (
        VALUES
          (ixus.last_user_seek),
          (ixus.last_user_scan),
          (ixus.last_user_lookup)
      ) dates (d)
  ) AS last_user_read,
  ixus.last_user_update
FROM
  [sys].[indexes] ix
  LEFT JOIN [sys].[dm_db_index_usage_stats] ixus ON ixus.index_id = ix.index_id
  AND ixus.[object_id] = ix.[object_id]
  AND DB_NAME(ixus.database_id) = DB_NAME()
WHERE
  OBJECTPROPERTY(ix.[object_id], 'isusertable') = 1
  AND ix.index_id > 1;
