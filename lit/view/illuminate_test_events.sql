CREATE OR ALTER VIEW
  lit.illuminate_test_events AS
WITH
  clean_data AS (
    SELECT
      local_student_id,
      date_administered,
      about_the_text,
      beyond_the_text,
      within_the_text,
      accuracy,
      fluency,
      reading_rate_wpm,
      instructional_level_tested,
      rate_proficiency,
      key_lever,
      fiction_nonfiction,
      NULL AS test_administered_by,
      academic_year,
      unique_id,
      test_round,
      [status],
      achieved_independent_level
    FROM
      gabby.lit.illuminate_test_events_current
    WHERE
      academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
    UNION ALL
    SELECT
      CAST(student_number AS INT) AS student_number,
      date_administered,
      CAST(about_the_text AS INT) AS about_the_text,
      CAST(beyond_the_text AS INT) AS beyond_the_text,
      CAST(within_the_text AS INT) AS within_the_text,
      CAST(accuracy AS INT) AS accuracy,
      CAST(fluency AS INT) AS fluency,
      reading_rate_wpm,
      CASE
        WHEN instructional_level_tested != '' THEN CAST(
          instructional_level_tested AS VARCHAR(5)
        )
      END AS instructional_level_tested,
      CASE
        WHEN rate_proficiency != '' THEN CAST(rate_proficiency AS VARCHAR(25))
      END AS rate_proficiency,
      CASE
        WHEN key_lever != '' THEN CAST(key_lever AS VARCHAR(25))
      END AS key_lever,
      CASE
        WHEN fiction_nonfiction != '' THEN CAST(fiction_nonfiction AS VARCHAR(5))
      END AS fiction_nonfiction,
      NULL AS test_administered_by,
      CAST(academic_year AS INT) AS academic_year,
      CAST(unique_id AS VARCHAR(125)) AS unique_id,
      CASE
        WHEN test_round != '' THEN CAST(test_round AS VARCHAR(25))
      END AS test_round,
      CASE
        WHEN [status] != '' THEN CAST([status] AS VARCHAR(25))
      END AS [status],
      CASE
        WHEN achieved_independent_level != '' THEN CAST(
          achieved_independent_level AS VARCHAR(5)
        )
      END AS achieved_independent_level
    FROM
      gabby.lit.illuminate_test_events_archive
  )
SELECT
  cd.unique_id,
  cd.local_student_id AS student_number,
  cd.academic_year,
  cd.test_round,
  cd.date_administered,
  cd.[status],
  cd.instructional_level_tested,
  cd.achieved_independent_level,
  cd.about_the_text,
  cd.beyond_the_text,
  cd.within_the_text,
  cd.accuracy,
  cd.fluency,
  cd.reading_rate_wpm,
  cd.rate_proficiency,
  cd.key_lever,
  cd.fiction_nonfiction,
  cd.test_administered_by AS test_administered_by,
  CASE
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'BOY'
    ) THEN 1
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'MOY'
    ) THEN 2
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'EOY'
    ) THEN 3
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'DR'
    ) THEN 1
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'Q1'
    ) THEN 2
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'Q2'
    ) THEN 3
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'Q3'
    ) THEN 4
    WHEN (
      cd.academic_year <= 2016
      AND cd.test_round = 'Q4'
    ) THEN 5
    WHEN (
      cd.academic_year >= 2017
      AND cd.test_round = 'Q1'
    ) THEN 1
    WHEN (
      cd.academic_year >= 2017
      AND cd.test_round = 'Q2'
    ) THEN 2
    WHEN (
      cd.academic_year >= 2017
      AND cd.test_round = 'Q3'
    ) THEN 3
    WHEN (
      cd.academic_year >= 2017
      AND cd.test_round = 'Q4'
    ) THEN 4
  END AS round_num,
  CASE
    WHEN (
      cd.about_the_text IS NULL
      AND cd.beyond_the_text IS NULL
      AND cd.within_the_text IS NULL
    ) THEN NULL
    /* trunk-ignore(sqlfluff/L016) */
    ELSE ISNULL(cd.within_the_text, 0) + ISNULL(cd.about_the_text, 0) + ISNULL(cd.beyond_the_text, 0)
  END AS comp_overall,
  achv.gleq,
  CAST(achv.lvl_num AS INT) AS gleq_lvl_num,
  CAST(achv.fp_lvl_num AS INT) AS indep_lvl_num,
  CAST(instr.fp_lvl_num AS INT) AS instr_lvl_num
FROM
  clean_data AS cd
  LEFT JOIN gabby.lit.gleq AS achv ON (
    cd.achieved_independent_level = achv.read_lvl
  )
  LEFT JOIN gabby.lit.gleq AS instr ON (
    cd.instructional_level_tested = instr.read_lvl
  )
