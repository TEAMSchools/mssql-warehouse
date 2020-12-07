SELECT atc.table_name
      ,'DROP INDEX [E: student_id, repository_row_id] ON [illuminate_dna_repositories].[' + atc.table_name + '];' AS drop_index_sql
      ,'CREATE UNIQUE NONCLUSTERED INDEX [E: student_id, repository_row_id] ON [illuminate_dna_repositories].[' + atc.table_name
         + '] ([student_id] ASC,[repository_row_id] ASC) INCLUDE('
         + gabby.dbo.GROUP_CONCAT('[' + column_name + ']')
         +') WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY];'
           AS create_index_sql
FROM gabby.illuminate_dna_repositories.repositories r
JOIN gabby.illuminate_codes.dna_scopes s
  ON r.code_scope_id = s.code_id
 AND s.code_translation = 'Sight Words Quiz'
LEFT JOIN gabby.utilities.all_tables_columns atc
  ON CONCAT('repository_', r.repository_id) = atc.table_name
 AND atc.schema_name = 'illuminate_dna_repositories'
 AND atc.column_id > 0
WHERE r.deleted_at IS NULL
  AND r.repository_id IN (SELECT DISTINCT repository_id FROM gabby.illuminate_dna_repositories.repository_row_ids)
  AND atc.column_name NOT IN ('repository_row_id', 'student_id')
  AND atc.column_name NOT LIKE '_fivetran%'
GROUP BY atc.table_name
ORDER BY atc.table_name DESC;