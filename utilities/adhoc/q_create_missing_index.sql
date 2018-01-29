SELECT *
     ,'CREATE NONCLUSTERED INDEX ' 
        + CONCAT('['
                ,LEFT(CONCAT('K: '
                            ,REPLACE(REPLACE(CONCAT(CASE 
                                                     WHEN equality_columns + inequality_columns IS NOT NULL THEN CONCAT(equality_columns, ', ', inequality_columns)
                                                     WHEN inequality_columns IS NULL THEN equality_columns
                                                     WHEN equality_columns IS NULL THEN inequality_columns
                                                    END
                                                   ,' I: ' + included_columns), '[', ''), ']', '')), 128), ']')
        + ' ON ' 
        + statement
        + ' ('
        + CASE 
           WHEN equality_columns + inequality_columns IS NOT NULL THEN CONCAT(equality_columns, ', ', inequality_columns)
           WHEN inequality_columns IS NULL THEN equality_columns
           WHEN equality_columns IS NULL THEN inequality_columns
          END
        + ') '
        + ISNULL('INCLUDE (' + included_columns + ')','')
        + ' WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];' AS create_index_script
FROM sys.dm_db_missing_index_details
ORDER BY statement, equality_columns, inequality_columns, included_columns