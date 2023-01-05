CREATE OR ALTER VIEW
  illuminate_dna_repositories.sight_words_quiz_union_generator AS
SELECT
  r.repository_id,
  r.title,
  illuminate_dna_repositories.repository_unpivot (r.repository_id) AS select_sql,
  CASE
    WHEN atc.table_name IS NULL THEN 1
    ELSE 0
  END AS is_missing
FROM
  illuminate_dna_repositories.repositories AS r
  INNER JOIN illuminate_codes.dna_scopes AS s ON (
    r.code_scope_id = s.code_id
    AND s.code_translation = 'Sight Words Quiz'
  )
  LEFT JOIN utilities.all_tables_columns AS atc ON (
    CONCAT('repository_', r.repository_id) = atc.table_name
    AND atc.[schema_name] = 'illuminate_dna_repositories'
    AND atc.column_id = -1
  )
WHERE
  r.deleted_at IS NULL
  AND r.date_administered >= DATEFROMPARTS(
    utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
