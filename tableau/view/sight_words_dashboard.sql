CREATE OR ALTER VIEW
  tableau.sight_words_dashboard AS
SELECT
  r.repository_id,
  r.title,
  r.date_administered,
  rt.alt_name AS term_name,
  rt.academic_year,
  f.[label] AS sight_word,
  co.student_number,
  co.lastfirst,
  co.region,
  co.reporting_schoolid,
  co.is_pathways,
  co.grade_level,
  co.team,
  co.iep_status,
  co.lep_status,
  co.gender,
  co.ethnicity,
  sw.[value],
  0 AS is_replacement
FROM
  gabby.illuminate_codes.dna_scopes AS ds
  INNER JOIN gabby.illuminate_dna_repositories.repositories AS r ON ds.code_id = r.code_scope_id
  AND r.deleted_at IS NULL
  INNER JOIN gabby.reporting.reporting_terms AS rt ON (
    r.date_administered BETWEEN rt.[start_date] AND rt.end_date
  )
  AND rt.schoolid = 0
  AND rt.identifier = 'RT'
  AND rt._fivetran_deleted = 0
  INNER JOIN gabby.illuminate_dna_repositories.fields AS f ON r.repository_id = f.repository_id
  AND f.deleted_at IS NULL
  INNER JOIN gabby.illuminate_dna_repositories.repository_grade_levels AS g ON r.repository_id = g.repository_id
  INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON g.grade_level_id = (co.grade_level + 1)
  AND rt.academic_year = co.academic_year
  AND co.is_enrolled_recent = 1
  AND co.rn_year = 1
  LEFT JOIN gabby.illuminate_dna_repositories.sight_words_data AS sw ON co.student_number = sw.local_student_id
  AND r.repository_id = sw.repository_id
  AND f.[label] = sw.[label]
WHERE
  ds.code_translation = 'Sight Words Quiz'
UNION ALL
SELECT
  r.repository_id,
  r.title,
  r.date_administered,
  rt.alt_name AS term_name,
  rt.academic_year,
  f.[label] AS sight_word,
  co.student_number,
  co.lastfirst,
  co.region,
  co.reporting_schoolid,
  co.is_pathways,
  co.grade_level,
  co.team,
  co.iep_status,
  co.lep_status,
  co.gender,
  co.ethnicity,
  sw.[value],
  1 AS is_replacement
FROM
  gabby.illuminate_codes.dna_scopes AS ds
  INNER JOIN gabby.illuminate_dna_repositories.repositories AS r ON ds.code_id = r.code_scope_id
  AND r.deleted_at IS NULL
  INNER JOIN gabby.reporting.reporting_terms AS rt ON (
    r.date_administered BETWEEN rt.[start_date] AND rt.end_date
  )
  AND rt.schoolid = 0
  AND rt.identifier = 'RT'
  AND rt._fivetran_deleted = 0
  INNER JOIN gabby.illuminate_dna_repositories.fields AS f ON r.repository_id = f.repository_id
  AND f.deleted_at IS NULL
  INNER JOIN gabby.illuminate_dna_repositories.repository_grade_levels AS g ON r.repository_id = g.repository_id
  INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON g.grade_level_id != (co.grade_level + 1)
  AND rt.academic_year = co.academic_year
  AND co.is_enrolled_recent = 1
  AND co.rn_year = 1
  INNER JOIN gabby.illuminate_dna_repositories.sight_words_data AS sw ON co.student_number = sw.local_student_id
  AND r.repository_id = sw.repository_id
  AND f.[label] = sw.[label]
WHERE
  ds.code_translation = 'Sight Words Quiz'
