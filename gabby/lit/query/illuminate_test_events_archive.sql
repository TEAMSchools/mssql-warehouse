SELECT
  s.local_student_id AS student_number,
  sub.[Instructional Level Tested] AS instructional_level_tested,
  sub.[Key Lever] AS key_lever,
  sub.[Fiction/ Nonfiction] AS fiction_nonfiction,
  sub.[Test Administered By] AS test_administered_by,
  sub.[Academic Year] AS academic_year,
  sub.[Test Round] AS test_round,
  CAST(sub.[Date Administered] AS DATE) AS date_administered,
  CAST(sub.[About the Text] AS FLOAT) AS about_the_text,
  CAST(sub.[Beyond the Text] AS FLOAT) AS beyond_the_text,
  CAST(sub.[Within the Text] AS FLOAT) AS within_the_text,
  CAST(sub.[Accuracy] AS FLOAT) AS accuracy,
  CAST(sub.[Fluency] AS FLOAT) AS fluency,
  CAST(
    sub.[Reading Rate (wpm)] AS FLOAT
  ) AS reading_rate_wpm,
  CAST(
    sub.[Rate Proficiency] AS NVARCHAR
  ) AS rate_proficiency,
  CONCAT(
    'IL',
    sub.repository_id,
    sub.repository_row_id
  ) AS unique_id,
  CASE
    WHEN LTRIM(RTRIM(sub.[Status])) LIKE '%Did Not Achieve%' THEN 'Did Not Achieve'
    WHEN LTRIM(RTRIM(sub.[Status])) LIKE '%Achieved%' THEN 'Achieved'
    ELSE LTRIM(RTRIM(sub.[Status]))
  END AS [status],
  COALESCE(
    sub.[Achieved Independent Level],
    CASE
      WHEN sub.[Status] LIKE '%Achieved%' THEN sub.[Instructional Level Tested]
    END
  ) AS achieved_independent_level
FROM
  (
    SELECT
      126 AS repository_id,
      repository_row_id,
      student_id,
      field_about_the_text AS [About the Text],
      LEFT(
        CAST(field_academic_year AS INT),
        4
      ) AS [Academic Year],
      field_accuracy_1 AS [Accuracy],
      field_level_tested AS [Achieved Independent Level],
      field_beyond_the_text AS [Beyond the Text],
      field_date_administered AS [Date Administered],
      field_fiction_nonfiction AS [Fiction/ Nonfiction],
      field_fluency_1 AS [Fluency],
      field_text_familiarity AS [Instructional Level Tested],
      field_key_lever AS [Key Lever],
      field_rate_proficiency AS [Rate Proficiency],
      field_reading_rate_wpm AS [Reading Rate (wpm)],
      'Mixed' AS [Status],
      field_test_administered_by AS [Test Administered By],
      field_test_round AS [Test Round],
      field_within_the_text AS [Within the Text]
    FROM
      illuminate_dna_repositories.repository_126
    UNION ALL
    SELECT
      169 AS repository_id,
      repository_row_id,
      student_id,
      field_about_the_text AS [About the Text],
      field_academic_year AS [Academic Year],
      field_accuracy_1 AS [Accuracy],
      NULL AS [Achieved Independent Level],
      field_beyond_the_text AS [Beyond the Text],
      field_date_administered AS [Date Administered],
      field_fiction_nonfiction AS [Fiction/ Nonfiction],
      field_fluency_1 AS [Fluency],
      field_text_familiarity AS [Instructional Level Tested],
      field_key_lever AS [Key Lever],
      field_rate_proficiency AS [Rate Proficiency],
      field_reading_rate_wpm AS [Reading Rate (wpm)],
      field_level_tested AS [Status],
      field_test_administered_by AS [Test Administered By],
      field_test_round AS [Test Round],
      field_within_the_text AS [Within the Text]
    FROM
      illuminate_dna_repositories.repository_169
    UNION ALL
    SELECT
      170 AS repository_id,
      repository_row_id,
      student_id,
      field_about_the_text AS [About the Text],
      field_academic_year AS [Academic Year],
      field_accuracy_1 AS [Accuracy],
      NULL AS [Achieved Independent Level],
      field_beyond_the_text AS [Beyond the Text],
      field_date_administered AS [Date Administered],
      field_fiction_nonfiction AS [Fiction/ Nonfiction],
      field_fluency_1 AS [Fluency],
      field_text_familiarity AS [Instructional Level Tested],
      field_key_lever AS [Key Lever],
      field_rate_proficiency AS [Rate Proficiency],
      field_reading_rate_wpm AS [Reading Rate (wpm)],
      field_level_tested AS [Status],
      field_test_administered_by AS [Test Administered By],
      field_test_round AS [Test Round],
      field_within_the_text AS [Within the Text]
    FROM
      illuminate_dna_repositories.repository_170
  ) AS sub
  INNER JOIN illuminate_public.students AS s ON (sub.student_id = s.student_id)
WHERE
  CONCAT(
    sub.repository_id,
    '_',
    sub.repository_row_id
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
ORDER BY
  sub.unique_id
