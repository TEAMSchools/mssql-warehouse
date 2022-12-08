USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_repositories.sight_words_quiz_union_generator AS

SELECT r.repository_id
      ,r.title
      ,gabby.illuminate_dna_repositories.repository_unpivot(r.repository_id) AS select_sql

      ,CASE WHEN atc.table_name IS NULL THEN 1 ELSE 0 END AS is_missing
FROM gabby.illuminate_dna_repositories.repositories r
INNER JOIN gabby.illuminate_codes.dna_scopes s
  ON r.code_scope_id = s.code_id
 AND s.code_translation = 'Sight Words Quiz'
LEFT JOIN gabby.utilities.all_tables_columns atc
  ON CONCAT('repository_', r.repository_id) = atc.table_name
 AND atc.[schema_name] = 'illuminate_dna_repositories'
 AND atc.column_id = -1
WHERE r.deleted_at IS NULL
  AND r.date_administered >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
