SELECT gabby.illuminate_dna_repositories.repository_unpivot(r.repository_id, DEFAULT, DEFAULT) + ' UNION ALL ' AS select_sql
FROM gabby.illuminate_dna_repositories.repositories r
JOIN gabby.illuminate_codes.dna_scopes s
  ON r.code_scope_id = s.code_id
 AND s.code_translation = 'Sight Words Quiz'
JOIN gabby.utilities.all_tables_columns atc
  ON CONCAT('repository_', r.repository_id) = atc.table_name
 AND atc.schema_name = 'illuminate_dna_repositories'
 AND atc.column_id = -1
WHERE r.deleted_at IS NULL
ORDER BY r.repository_id;