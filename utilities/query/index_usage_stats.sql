SELECT
  SCHEMA_NAME(t.[schema_id]) AS [schema_name],
  OBJECT_NAME(ix.[object_id]) AS table_name,
  ix.[name]
COLLATE latin1_general_bin AS index_name,
ixus.user_seeks AS numofseeks,
ixus.user_scans AS numofscans,
ixus.user_lookups AS numoflookups,
ixus.user_seeks + ixus.user_scans + ixus.user_lookups AS numofreads,
ixus.last_user_seek AS lastseek,
ixus.last_user_scan AS lastscan,
ixus.last_user_lookup AS lastlookup,
(
  SELECT
    MAX(lastread)
  FROM
    (
      VALUES
        (ixus.last_user_seek),
        (ixus.last_user_scan),
        (ixus.last_user_lookup)
    ) AS allreads (lastread)
) AS lastread
-- ,ixus.user_updates AS NumOfUpdates
-- ,ixus.last_user_update AS LastUpdate
FROM
  sys.indexes ix
  JOIN sys.objects t ON ix.[object_id] = t.[object_id]
  INNER JOIN sys.dm_db_index_usage_stats ixus ON ixus.index_id = ix.index_id
  AND ixus.[object_id] = ix.[object_id]
  INNER JOIN sys.dm_db_partition_stats ps ON ps.[object_id] = ix.[object_id]
WHERE
  OBJECTPROPERTY(ix.[object_id], 'isusertable') = 1
  AND ix.is_primary_key = 0
  AND ix.[type_desc] = 'NONCLUSTERED'
  AND ix.[name] <> 'CoveringIndex'
