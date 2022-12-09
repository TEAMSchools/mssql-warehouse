use gabby go
select
  concat(atc.[db_name], '.', atc.[schema_name], '.', atc.table_name)
collate latin1_general_bin as source_object,
atc.[type],
concat(db_name(), '.', sre.referencing_schema_name, '.', sre.referencing_entity_name) as referencing_object
from
  gabby.utilities.all_tables_columns atc
  cross apply [sys].[dm_sql_referencing_entities] (concat(atc.[schema_name], '.', atc.[table_name]), 'OBJECT') sre
where
  atc.column_id = -1
order by
  sre.referencing_schema_name,
  sre.referencing_entity_name
