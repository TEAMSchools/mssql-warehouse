USE gabby GO
CREATE OR ALTER VIEW
  njsmart.all_state_assessments AS
WITH
  combined_unpivot AS (
    SELECT
      local_student_id,
      academic_year,
      test_type,
      field,
      VALUE
    FROM
      (
        SELECT
          CAST(local_student_id AS INT) AS local_student_id,
          CAST(SUBSTRING(_file, PATINDEX('%- [0-9][0-9][0-9][0-9]%', _file) + 2, 4) AS INT) AS academic_year,
          'NJASK' AS test_type,
          CAST(scaled_score_lal AS VARCHAR(50)) AS scaled_score_lal,
          CAST(performance_level_lal AS VARCHAR(50)) AS performance_level_lal,
          CAST(invalid_scale_score_reason_lal AS VARCHAR(50)) AS invalid_scale_score_reason_lal,
          CAST(void_reason_lal AS VARCHAR(50)) AS void_reason_lal,
          CAST(scaled_score_math AS VARCHAR(50)) AS scaled_score_math,
          CAST(performance_level_math AS VARCHAR(50)) AS performance_level_math,
          CAST(invalid_scale_score_reason_math AS VARCHAR(50)) AS invalid_scale_score_reason_math,
          CAST(void_reason_math AS VARCHAR(50)) AS void_reason_math,
          CAST(scaled_score_science AS VARCHAR(50)) AS scaled_score_science,
          CAST(performance_level_science AS VARCHAR(50)) AS performance_level_science,
          CAST(invalid_scale_score_reason_science AS VARCHAR(50)) AS invalid_scale_score_reason_science,
          CAST(void_reason_science AS VARCHAR(50)) AS void_reason_science
        FROM
          gabby.njsmart.njask_archive
        UNION ALL
        SELECT
          CAST(local_student_id AS INT) AS local_student_id,
          CAST((testing_year - 1) AS INT) AS academic_year,
          'NJASK' AS test_type,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          CAST(science_scale_score AS VARCHAR(50)) AS science_scale_score,
          CAST(science_proficiency_level AS VARCHAR(50)) AS science_proficiency_level,
          CAST(
            CASE
              WHEN science_invalid_scale_score_reason = '' THEN NULL
              ELSE science_invalid_scale_score_reason
            END AS VARCHAR(50)
          ) AS science_invalid_scale_score_reason,
          CAST(
            CASE
              WHEN void_reason_science = '' THEN NULL
              ELSE void_reason_science
            END AS VARCHAR(50)
          ) AS void_reason_science
        FROM
          gabby.njsmart.njask
        UNION ALL
        SELECT
          CAST(local_student_id AS INT) AS local_student_id,
          CAST((testing_year - 1) AS INT) AS academic_year,
          'NJBCT' AS test_type,
          NULL AS scaled_score_lal,
          NULL AS performance_level_lal,
          NULL AS invalid_scale_score_reason_lal,
          NULL AS void_reason_lal,
          NULL AS scaled_score_math,
          NULL AS performance_level_math,
          NULL AS invalid_scale_score_reason_math,
          NULL AS void_reason_math,
          CAST(scale_score AS VARCHAR(50)) AS scaled_score_science,
          CAST(proficiency_level AS VARCHAR(50)) AS performance_level_science,
          NULL AS invalid_scale_score_reason,
          CAST(
            CASE
              WHEN void_reason = '' THEN NULL
              ELSE void_reason
            END AS VARCHAR(50)
          ) AS void_reason_science
        FROM
          gabby.njsmart.njbct n
        UNION ALL
        SELECT
          CAST(CONVERT(FLOAT, REPLACE(local_student_id, ' ', '')) AS BIGINT) AS local_student_id,
          CAST(SUBSTRING(_file, PATINDEX('%- [0-9][0-9][0-9][0-9]%', _file) + 2, 4) AS INT) AS academic_year,
          'HSPA' AS test_type,
          CAST(scaled_score_lal AS VARCHAR(50)) AS scaled_score_lal,
          CAST(performance_level_lal AS VARCHAR(50)) AS performance_level_lal,
          CAST(invalid_scale_score_reason_lal AS VARCHAR(50)) AS invalid_scale_score_reason_lal,
          CAST(void_reason_lal AS VARCHAR(50)) AS void_reason_lal,
          CAST(scaled_score_math AS VARCHAR(50)) AS scaled_score_math,
          CAST(performance_level_math AS VARCHAR(50)) AS performance_level_math,
          CAST(invalid_scale_score_reason_math AS VARCHAR(50)) AS invalid_scale_score_reason_math,
          CAST(void_reason_math AS VARCHAR(50)) AS void_reason_math,
          NULL AS scaled_score_science,
          NULL AS performance_level_science,
          NULL AS invalid_scale_score_reason_science,
          NULL AS void_reason_science
        FROM
          gabby.njsmart.hspa
        UNION ALL
        SELECT
          CAST(local_student_id AS INT) AS local_student_id,
          CAST(SUBSTRING(_file, PATINDEX('%- [0-9][0-9][0-9][0-9]%', _file) + 2, 4) AS INT) AS academic_year,
          'GEPA' AS test_type,
          CAST(scaled_score_lang AS VARCHAR(50)) AS scaled_score_lal,
          CAST(performance_level_lang AS VARCHAR(50)) AS performance_level_lal,
          NULL AS invalid_scale_score_reason_lal,
          CAST(void_reason_lang AS VARCHAR(50)) AS void_reason_lal,
          CAST(scaled_score_math AS VARCHAR(50)) AS scaled_score_math,
          CAST(performance_level_math AS VARCHAR(50)) AS performance_level_math,
          NULL AS invalid_scale_score_reason_math,
          CAST(void_reason_math AS VARCHAR(50)) AS void_reason_math,
          CAST(scaled_score_science AS VARCHAR(50)) AS scaled_score_science,
          CAST(performance_level_science AS VARCHAR(50)) AS performance_level_science,
          NULL AS invalid_scale_score_reason_science,
          CAST(void_reason_science AS VARCHAR(50)) AS void_reason_science
        FROM
          gabby.njsmart.gepa
      ) sub UNPIVOT (
        VALUE FOR field IN (
          scaled_score_lal,
          performance_level_lal,
          invalid_scale_score_reason_lal,
          void_reason_lal,
          scaled_score_math,
          performance_level_math,
          invalid_scale_score_reason_math,
          void_reason_math,
          scaled_score_science,
          performance_level_science,
          invalid_scale_score_reason_science,
          void_reason_science
        )
      ) u
  ),
  combined_repivot AS (
    SELECT
      local_student_id,
      academic_year,
      test_type,
      CAST(subject AS VARCHAR(250)) AS subject,
      CAST(scaled_score AS FLOAT) AS scaled_score,
      performance_level,
      invalid_scale_score_reason,
      void_reason
    FROM
      (
        SELECT
          local_student_id,
          academic_year,
          test_type,
          VALUE,
          UPPER(REVERSE(LEFT(REVERSE(field), (CHARINDEX('_', REVERSE(field)) - 1)))) AS subject,
          REVERSE(SUBSTRING(REVERSE(field), (CHARINDEX('_', REVERSE(field)) + 1), LEN(field))) AS field
        FROM
          combined_unpivot
      ) sub PIVOT (
        MAX(VALUE) FOR field IN (scaled_score, performance_level, invalid_scale_score_reason, void_reason)
      ) p
  )
SELECT
  local_student_id,
  academic_year,
  test_type,
  subject,
  scaled_score,
  performance_level
FROM
  (
    SELECT
      local_student_id,
      academic_year,
      test_type,
      CASE
        WHEN subject = 'LAL' THEN 'ELA'
        ELSE subject
      END AS subject,
      CASE
        WHEN scaled_score = 0 THEN NULL
        ELSE scaled_score
      END AS scaled_score,
      CASE
        WHEN performance_level = '3' THEN 'Partially Proficient'
        WHEN performance_level = '2' THEN 'Proficient'
        WHEN performance_level = '1' THEN 'Advanced Proficient'
        ELSE performance_level
      END AS performance_level,
      ROW_NUMBER() OVER (
        PARTITION BY
          local_student_id,
          test_type,
          subject,
          academic_year
        ORDER BY
          scaled_score DESC
      ) AS rn_highscore_yr
    FROM
      combined_repivot
    WHERE
      ISNULL(invalid_scale_score_reason, 'No') = 'No'
      AND ISNULL(void_reason, 'No') = 'No'
  ) sub
WHERE
  rn_highscore_yr = 1
