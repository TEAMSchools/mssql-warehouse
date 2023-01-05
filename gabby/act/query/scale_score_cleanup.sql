WITH
  key_clean AS (
    SELECT
      [subject],
      scale AS scale_score,
      CASE
        WHEN raw_score LIKE '%-%' THEN CAST(
          LEFT(
            raw_score,
            CHARINDEX('-', raw_score) - 1
          ) AS INT
        )
        WHEN ISNUMERIC(raw_score) = 0 THEN NULL
        ELSE CAST(raw_score AS INT)
      END AS raw_score
    FROM
      act.key_cleanup UNPIVOT (
        raw_score FOR [subject] IN (
          english,
          mathematics,
          reading,
          science
        )
      ) AS u
  ),
  scaffold AS (
    SELECT
      [subject],
      MAX(raw_score) AS max_raw_score
    FROM
      key_clean
    GROUP BY
      [subject]
    UNION ALL
    SELECT
      [subject],
      max_raw_score - 1 AS max_raw_score
    FROM
      scaffold
    WHERE
      max_raw_score > 0
  )
SELECT DISTINCT
  /* UPDATE */
  'ACT1' AS administration_round,
  scaffold.max_raw_score AS raw_score,
  row_generator.n AS grade_level,
  utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year,
  (
    UPPER(LEFT(scaffold.subject, 1)) + (
      SUBSTRING(
        scaffold.subject,
        2,
        LEN(scaffold.subject)
      )
    )
  ) AS [subject],
  MAX(key_clean.scale_score) OVER (
    PARTITION BY
      scaffold.subject
    ORDER BY
      scaffold.max_raw_score
  ) AS scale_score
FROM
  scaffold
  LEFT OUTER JOIN key_clean ON (
    scaffold.subject = key_clean.subject
    AND scaffold.max_raw_score = key_clean.raw_score
  )
  INNER JOIN utilities.row_generator ON (
    utilities.row_generator.n BETWEEN 9 AND 11
  )
