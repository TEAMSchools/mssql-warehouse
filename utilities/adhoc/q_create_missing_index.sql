SELECT *
     ,'CREATE NONCLUSTERED INDEX ' 
        + CONCAT('[', LEFT(CONCAT('K: ', REPLACE(REPLACE(CONCAT(equality_columns, ',' + inequality_columns, ' I: ' + included_columns), '[', ''), ']', '')), 128), ']')
        + ' ON ' 
        + statement
        + '(' + CONCAT(equality_columns, ',' + inequality_columns) + ')'
        + ISNULL(' INCLUDE (' + included_columns + ')','')
        + ' WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]' AS create_index_script
FROM sys.dm_db_missing_index_details