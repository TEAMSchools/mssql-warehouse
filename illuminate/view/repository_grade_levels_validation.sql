CREATE OR ALTER VIEW
  illuminate_dna_repositories.repository_grade_levels_validation AS
SELECT
  *
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT repo_grade_level_id
  FROM dna_repositories.repository_grade_levels
'
  )
