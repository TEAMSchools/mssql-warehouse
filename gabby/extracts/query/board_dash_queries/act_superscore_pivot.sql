SELECT
  contact_c,
  [act_english_c] AS max_english,
  [act_math_c] AS max_math,
  [act_reading_c] AS max_reading,
  [act_science_c] AS max_science,
  [act_composite_c] AS max_composite,
  ROUND(
    (
      [act_english_c] + [act_math_c] + [act_reading_c] + [act_science_c]
    ) / 4,
    0
  ) AS act_superscore
FROM
  (
    SELECT
      st.contact_c,
      st.score_type,
      MAX(st.score) AS max_score
    FROM
      gabby.alumni.standardized_test_long AS st
    WHERE
      st.test_type = 'ACT'
      AND st.score_type IN (
        'act_english_c',
        'act_math_c',
        'act_reading_c',
        'act_science_c',
        'act_composite_c'
      )
    GROUP BY
      st.contact_c,
      st.score_type
  ) AS sub PIVOT (
    MAX(max_score) FOR score_type IN (
      [act_english_c],
      [act_math_c],
      [act_reading_c],
      [act_science_c],
      [act_composite_c]
    )
  ) AS p
