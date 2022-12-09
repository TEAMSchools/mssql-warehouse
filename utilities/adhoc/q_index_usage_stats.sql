select
  schema_name(t.[schema_id]) as [schema_name],
  object_name(ix.[object_id]) as table_name,
  ix.[name]
collate latin1_general_bin as index_name,
ixus.user_seeks as numofseeks,
ixus.user_scans as numofscans,
ixus.user_lookups as numoflookups,
ixus.user_seeks + ixus.user_scans + ixus.user_lookups as numofreads,
ixus.last_user_seek as lastseek,
ixus.last_user_scan as lastscan,
ixus.last_user_lookup as lastlookup,
(
  select
    max(lastread)
  from
    (
      values
        (ixus.last_user_seek),
        (ixus.last_user_scan),
        (ixus.last_user_lookup)
    ) as allreads (lastread)
) as lastread
-- ,ixus.user_updates AS NumOfUpdates
-- ,ixus.last_user_update AS LastUpdate
from
  sys.indexes ix
  join sys.objects t on ix.[object_id] = t.[object_id]
  inner join sys.dm_db_index_usage_stats ixus on ixus.index_id = ix.index_id
  and ixus.[object_id] = ix.[object_id]
  inner join sys.dm_db_partition_stats ps on ps.[object_id] = ix.[object_id]
where
  objectproperty(ix.[object_id], 'isusertable') = 1
  and ix.is_primary_key = 0
  and ix.[type_desc] = 'NONCLUSTERED'
  and ix.[name] <> 'CoveringIndex'
