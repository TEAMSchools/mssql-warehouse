USE gabby GO
CREATE OR ALTER VIEW
  alumni.enrollment_term_status AS
WITH
  term_scaff AS (
    SELECT
      rg.n AS term_year,
      ss.[value] AS term_season,
      DATEFROMPARTS(
        rg.n,
        CASE
          WHEN ss.[value] = 'Spring' THEN 1
          WHEN ss.[value] = 'Fall' THEN 8
        END,
        1
      ) AS term_start_date,
      DATEFROMPARTS(
        rg.n,
        CASE
          WHEN ss.[value] = 'Spring' THEN 7
          WHEN ss.[value] = 'Fall' THEN 12
        END,
        31
      ) AS term_end_date
    FROM
      gabby.utilities.row_generator_smallint rg
      CROSS JOIN STRING_SPLIT ('Spring,Fall', ',') ss
    WHERE
      rg.n BETWEEN 2010 AND (gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 2)
  ),
  enr_scaff AS (
    SELECT
      e.id AS enrollment_id,
      ts.term_year,
      ts.term_season,
      ROW_NUMBER() OVER (
        PARTITION BY
          e.id
        ORDER BY
          ts.term_start_date ASC
      ) AS rn_term_asc
    FROM
      gabby.alumni.enrollment_c e
      INNER JOIN term_scaff ts ON ts.term_start_date BETWEEN e.start_date_c AND COALESCE(e.actual_end_date_c, CAST(CURRENT_TIMESTAMP AS DATE))
    WHERE
      e.is_deleted = 0
  )
SELECT
  enrollment_id,
  [1],
  [2],
  [3],
  [4],
  [5],
  [6],
  [7],
  [8],
  [9],
  [10],
  [11],
  [12]
FROM
  (
    SELECT
      es.enrollment_id,
      es.rn_term_asc
      --,es.term_year
      --,es.term_season
,
      CASE
        WHEN t.term_enrollment_status_c IS NOT NULL THEN 1.0
        ELSE 0.0
      END AS is_enrolled_term
      --,t.term_enrollment_status_c AS term_enrollment_status
      --,t.term_verification_status_c AS term_verification_status
    FROM
      enr_scaff es
      LEFT JOIN gabby.alumni.term_c t ON es.enrollment_id = t.enrollment_c
      AND es.term_year = t.year_c
      AND es.term_season = t.term_season_c
      AND t.is_deleted = 0
  ) sub PIVOT (
    MAX(is_enrolled_term) FOR rn_term_asc IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
  ) p
