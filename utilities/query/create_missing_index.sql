SELECT
  index_handle,
  database_id,
  [object_id],
  equality_columns,
  inequality_columns,
  included_columns,
  [statement],
  'CREATE NONCLUSTERED INDEX [' + REPLACE(
    REPLACE(
      CASE
        WHEN equality_columns + inequality_columns IS NOT NULL THEN CONCAT(
          'E: ',
          equality_columns,
          ', I: ',
          inequality_columns
        )
        WHEN inequality_columns IS NULL THEN 'E: ' + equality_columns
        WHEN equality_columns IS NULL THEN 'I: ' + inequality_columns
      END,
      ']',
      ''
    ),
    '[',
    ''
  ) + '] ON ' + statement + ' (' + CASE
    WHEN equality_columns + inequality_columns IS NOT NULL THEN CONCAT(
      equality_columns,
      ', ',
      inequality_columns
    )
    WHEN inequality_columns IS NULL THEN equality_columns
    WHEN equality_columns IS NULL THEN inequality_columns
  END + ') ' + CASE
    WHEN included_columns IS NOT NULL THEN 'INCLUDE (' + included_columns + ') '
    ELSE ''
  END + 'WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];' AS create_index_script
FROM
  sys.dm_db_missing_index_details
WHERE
  database_id = DB_ID()
ORDER BY
  [statement],
  equality_columns,
  inequality_columns,
  included_columns
