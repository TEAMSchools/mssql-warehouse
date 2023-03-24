WITH
  act_taken AS (
    SELECT
      st.contact_c,
      MAX(st.date_c) AS max_date,
      MAX(st.score) AS max_act
    FROM
      gabby.alumni.standardized_test_long AS st
    WHERE
      st.test_type = 'ACT'
      AND st.score_type = 'act_composite_c'
    GROUP BY
      st.contact_c
  ),
  act_superscore AS (
    SELECT
      contact_c,
      [act_english_c] AS max_english,
      [act_math_c] AS max_math,
      [act_reading_c] AS max_reading,
      [act_science_c] AS max_science,
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
            'act_science_c'
          )
        GROUP BY
          st.contact_c,
          st.score_type
      ) AS sub PIVOT (
        MAX(max_score) FOR score_type IN (
          [act_english_c],
          [act_math_c],
          [act_reading_c],
          [act_science_c]
        )
      ) AS p
  )
SELECT
  kt.ktc_cohort,
  ROUND(AVG(act.max_act), 0) AS avg_max_act,
  ROUND(AVG(su.act_superscore), 0) AS avg_super_act,
  ROUND(
    AVG(
      CAST(
        CASE
          WHEN act.max_act IS NOT NULL THEN 1
          ELSE 0
        END AS FLOAT
      )
    ),
    3
  ) AS pct_act_taken
FROM
  gabby.alumni.ktc_roster AS kt
  LEFT JOIN act_taken AS act ON (kt.sf_contact_id = act.contact_c)
  LEFT JOIN act_superscore AS su ON (kt.sf_contact_id = su.contact_c)
WHERE
  kt.ktc_status NOT LIKE 'TAF%'
GROUP BY
  kt.ktc_cohort
ORDER BY
  kt.ktc_cohort ASC
