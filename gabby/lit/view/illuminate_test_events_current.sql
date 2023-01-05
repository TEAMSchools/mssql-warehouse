CREATE OR ALTER VIEW
  lit.illuminate_test_events_current AS
WITH
  repo_union AS (
    SELECT
      194 AS repository_id,
      2017 AS academic_year,
      'Q1' AS test_round,
      repository_row_id,
      student_id,
      field_about_the_text AS about_the_text,
      field_accuracy AS accuracy,
      field_beyond_the_text AS beyond_the_text,
      field_comprehension_1 AS comprehension,
      field_date_administered AS date_administered,
      field_fictionnonfiction AS fiction_nonfiction,
      field_fluency_score AS fluency_score,
      field_key_lever AS key_lever,
      field_rate_proficiency AS rate_proficiency,
      field_reading_level AS reading_level,
      field_words_per_minute AS reading_rate_wpm,
      field_status AS [status],
      field_comprehension AS within_the_text,
      field_writing_optional AS writing
    FROM
      illuminate_dna_repositories.repository_194
    UNION ALL
    SELECT
      195 AS repository_id,
      2017 AS academic_year,
      'Q2' AS test_round,
      repository_row_id,
      student_id,
      field_about_the_text AS about_the_text,
      field_accuracy AS accuracy,
      field_beyond_the_text AS beyond_the_text,
      field_comprehension_1 AS comprehension,
      field_date_administered AS date_administered,
      field_fictionnonfiction AS fiction_nonfiction,
      field_fluency_score AS fluency_score,
      field_key_lever AS key_lever,
      field_rate_proficiency AS rate_proficiency,
      field_reading_level AS reading_level,
      field_words_per_minute AS reading_rate_wpm,
      field_status AS [status],
      field_within_the_text AS within_the_text,
      field_writing_optional AS writing
    FROM
      illuminate_dna_repositories.repository_195
    UNION ALL
    SELECT
      196 AS repository_id,
      2017 AS academic_year,
      'Q3' AS test_round,
      repository_row_id,
      student_id,
      field_about_the_text AS about_the_text,
      field_accuracy AS accuracy,
      field_beyond_the_text AS beyond_the_text,
      field_comprehension_2 AS comprehension,
      field_date_administered AS date_administered,
      field_fictionnonfiction AS fiction_nonfiction,
      field_fluency_score AS fluency_score,
      field_key_lever AS key_lever,
      field_rate_proficiency AS rate_proficiency,
      field_reading_level AS reading_level,
      field_words_per_minute AS reading_rate_wpm,
      field_status AS [status],
      field_within_the_text AS within_the_text,
      field_writing_optional AS writing
    FROM
      illuminate_dna_repositories.repository_196
    UNION ALL
    SELECT
      193 AS repository_id,
      2017 AS academic_year,
      'Q4' AS test_round,
      repository_row_id,
      student_id,
      field_about_the_text AS about_the_text,
      field_accuracy AS accuracy,
      field_beyond_the_text AS beyond_the_text,
      field_comprehension_1 AS comprehension,
      field_date_administered_1 AS date_administered,
      field_fictionnonfiction AS fiction_nonfiction,
      field_fluency_score AS fluency_score,
      field_key_lever AS key_lever,
      field_rate_proficiency AS rate_proficiency,
      field_reading_level AS reading_level,
      field_words_per_minute AS reading_rate_wpm,
      field_status AS [status],
      field_within_the_text AS within_the_text,
      field_writing_optional AS writing
    FROM
      illuminate_dna_repositories.repository_193
  ),
  repos_clean AS (
    SELECT
      student_id,
      academic_year,
      test_round,
      CAST(date_administered AS DATE) AS date_administered,
      CAST(about_the_text AS FLOAT) AS about_the_text,
      CAST(beyond_the_text AS FLOAT) AS beyond_the_text,
      CAST(within_the_text AS FLOAT) AS within_the_text,
      CAST(accuracy AS FLOAT) AS accuracy,
      CAST(fluency_score AS FLOAT) AS fluency,
      CAST(reading_rate_wpm AS FLOAT) AS reading_rate_wpm,
      CAST(reading_level AS VARCHAR(5)) AS instructional_level_tested,
      CAST(rate_proficiency AS VARCHAR(25)) AS rate_proficiency,
      CAST(key_lever AS VARCHAR(25)) AS key_lever,
      CAST(fiction_nonfiction AS VARCHAR(5)) AS fiction_nonfiction,
      CONCAT(
        'IL',
        repository_id,
        repository_row_id
      ) AS unique_id,
      CASE
        WHEN LTRIM(RTRIM([status])) LIKE '%Did Not Achieve%' THEN 'Did Not Achieve'
        WHEN LTRIM(RTRIM([status])) LIKE '%Achieved%' THEN 'Achieved'
        ELSE CAST(
          LTRIM(RTRIM([status])) AS VARCHAR(25)
        )
      END AS [status],
      CASE
        WHEN [status] LIKE '%Achieved%' THEN CAST(reading_level AS VARCHAR(5))
      END AS achieved_independent_level
    FROM
      repo_union
    WHERE
      CONCAT(
        repository_id,
        '_',
        repository_row_id
      ) IN (
        SELECT
          CONCAT(
            repository_id,
            '_',
            repository_row_id
          )
        FROM
          illuminate_dna_repositories.repository_row_ids
      )
  )
SELECT
  CAST(s.local_student_id AS INT) AS local_student_id,
  rc.date_administered,
  rc.about_the_text,
  rc.beyond_the_text,
  rc.within_the_text,
  rc.accuracy,
  rc.fluency,
  rc.reading_rate_wpm,
  rc.instructional_level_tested,
  rc.rate_proficiency,
  rc.key_lever,
  rc.fiction_nonfiction,
  NULL AS test_administered_by,
  rc.academic_year,
  rc.unique_id,
  rc.test_round,
  rc.status,
  rc.achieved_independent_level
FROM
  repos_clean AS rc
  INNER JOIN illuminate_public.students AS s ON (rc.student_id = s.student_id)
