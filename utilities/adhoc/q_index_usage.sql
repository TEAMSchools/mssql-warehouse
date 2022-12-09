select
  db_name() as [db_name],
  object_schema_name(ix.[object_id]) as [schema_name],
  object_name(ix.[object_id]) as table_name,
  ix.[name] as index_name,
  isnull(ixus.user_seeks, 0) + isnull(ixus.user_scans, 0) + isnull(ixus.user_lookups, 0) as total_reads,
  isnull(ixus.user_updates, 0) as total_writes,
  case
    when (
      isnull(ixus.user_seeks, 0) + isnull(ixus.user_scans, 0) + isnull(ixus.user_lookups, 0) + isnull(ixus.user_updates, 0)
    ) = 0 then 0
    else cast(
      (
        isnull(ixus.user_seeks, 0) + isnull(ixus.user_scans, 0) + isnull(ixus.user_lookups, 0) as float
      ) / cast(
        (
          isnull(ixus.user_seeks, 0) + isnull(ixus.user_scans, 0) + isnull(ixus.user_lookups, 0) + isnull(ixus.user_updates, 0)
        )
      ) as float
    )
  end as pct_reads,
  (
    select
      max(dates.d)
    from
      (
        values
          (ixus.last_user_seek),
          (ixus.last_user_scan),
          (ixus.last_user_lookup)
      ) dates (d)
  ) as last_user_read,
  ixus.last_user_update
from
  [sys].[indexes] ix
  left join [sys].[dm_db_index_usage_stats] ixus on ixus.index_id = ix.index_id
  and ixus.[object_id] = ix.[object_id]
  and db_name(ixus.database_id) = db_name()
where
  objectproperty(ix.[object_id], 'isusertable') = 1
  and ix.index_id > 1;
