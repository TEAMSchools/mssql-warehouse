CREATE OR ALTER VIEW
  illuminate_dna_repositories.sight_words_data AS
SELECT
  c.repository_id,
  c.repository_row_id,
  c.[value],
  c.[label],
  c.local_student_id,
  c.date_administered
FROM
  gabby.illuminate_dna_repositories.sight_words_data_current_static AS c
UNION ALL
SELECT
  a.repository_id,
  a.repository_row_id,
  a.[value],
  a.[label],
  a.local_student_id,
  a.date_administered
FROM
  gabby.illuminate_dna_repositories.sight_words_data_archive AS a
