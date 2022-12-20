CREATE OR ALTER VIEW
  extracts.deanslist_sight_words AS
SELECT
  swd.local_student_id AS student_number,
  swd.date_administered,
  swd.[label] AS word,
  rt.alt_name AS term_name,
  CASE
    WHEN swd.[value] = 'yes' THEN 'Mastered'
    WHEN swd.[value] = 'no' THEN 'Not Mastered'
    WHEN swd.[value] = 'retested' THEN 'Retested'
  END AS mastery_status,
  CASE
    WHEN swd.[value] = 'yes' THEN 1
    WHEN swd.[value] = 'retested' THEN 1
    WHEN swd.[value] = 'no' THEN 0
  END AS is_mastery
FROM
  gabby.illuminate_dna_repositories.sight_words_data_current_static AS swd
  INNER JOIN gabby.reporting.reporting_terms AS rt ON (
    (
      swd.date_administered BETWEEN rt.[start_date] AND rt.end_date
    )
    AND rt.identifier = 'RT'
    AND rt.schoolid = 0
    AND rt._fivetran_deleted = 0
  )
