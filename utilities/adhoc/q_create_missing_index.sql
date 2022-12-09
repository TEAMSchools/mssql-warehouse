use gabby go
select
  *,
  'CREATE NONCLUSTERED INDEX [' + replace(
    replace(
      case
        when equality_columns + inequality_columns is not null then concat('E: ', equality_columns, ', I: ', inequality_columns)
        when inequality_columns is null then 'E: ' + equality_columns
        when equality_columns is null then 'I: ' + inequality_columns
      end,
      ']',
      ''
    ),
    '[',
    ''
  ) + '] ON ' + statement + ' (' + case
    when equality_columns + inequality_columns is not null then concat(equality_columns, ', ', inequality_columns)
    when inequality_columns is null then equality_columns
    when equality_columns is null then inequality_columns
  end + ') ' + case
    when included_columns is not null then 'INCLUDE (' + included_columns + ') '
    else ''
  end + 'WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];' as create_index_script
from
  sys.dm_db_missing_index_details
where
  database_id = db_id()
order by
  [statement],
  equality_columns,
  inequality_columns,
  included_columns
