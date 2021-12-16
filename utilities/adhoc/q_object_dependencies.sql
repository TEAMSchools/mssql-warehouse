USE gabby
GO

SELECT CONCAT(atc.[db_name], '.', atc.[schema_name], '.', atc.table_name) COLLATE Latin1_General_BIN AS source_object
      ,atc.[type]

      ,CONCAT(DB_NAME(), '.', sre.referencing_schema_name, '.', sre.referencing_entity_name) AS referencing_object
FROM gabby.utilities.all_tables_columns atc
CROSS APPLY [sys].[dm_sql_referencing_entities](CONCAT(atc.[schema_name], '.', atc.[table_name]), 'OBJECT') sre
WHERE atc.column_id = -1
ORDER BY sre.referencing_schema_name, sre.referencing_entity_name
