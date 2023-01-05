CREATE OR ALTER VIEW
  illuminate_dna_repositories.sight_words_data AS
SELECT
  repository_id,
  repository_row_id,
  [value],
  [label],
  local_student_id,
  date_administered
FROM
  illuminate_dna_repositories.sight_words_data_current_static
UNION ALL
SELECT
  repository_id,
  repository_row_id,
  [value],
  [label],
  local_student_id,
  date_administered
FROM
  illuminate_dna_repositories.sight_words_data_archive
