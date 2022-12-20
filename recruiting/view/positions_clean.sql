CREATE OR ALTER VIEW
  recruiting.positions_clean AS
SELECT
  p.position_number,
  p.position_name,
  p.city,
  p.job_type,
  p.sub_type,
  p.status,
  p.new_or_replacement,
  p.region,
  p.desired_start_date,
  p.created_date,
  p.date_filled,
  p.position_count,
  CASE
    WHEN p.n = 4 THEN PARSENAME(
      p.position_name_splitter,
      4
    )
    ELSE 'Invalid position_name Format'
  END AS recruiter,
  CASE
    WHEN p.n = 4 THEN PARSENAME(
      p.position_name_splitter,
      3
    )
    ELSE 'Invalid position_name Format'
  END AS location,
  CASE
    WHEN p.n = 4 THEN PARSENAME(
      p.position_name_splitter,
      2
    )
    ELSE 'Invalid position_name Format'
  END AS role_short,
  CASE
    WHEN p.n = 4 THEN PARSENAME(
      p.position_name_splitter,
      1
    )
    ELSE 'Invalid position_name Format'
  END AS recruiing_year
FROM
  (
    SELECT
      pn.name AS position_number,
      pn.position_name_c AS position_name,
      pn.city_c AS city,
      pn.desired_start_date_c AS desired_start_date,
      pn.created_date,
      pn.job_type_c AS job_type,
      pn.job_sub_type_c AS sub_type,
      pn.status_c AS status,
      pn.date_position_filled_c AS date_filled,
      pn.replacement_or_new_position_c AS new_or_replacement,
      pn.region_c AS region,
      LEN(pn.position_name_c) - LEN(
        REPLACE(
          pn.position_name_c,
          '_',
          ''
        )
      ) AS n,
      REPLACE(
        LEFT(
          pn.position_name_c,
          LEN(pn.position_name_c) - CHARINDEX(
            '_',
            REVERSE(pn.position_name_c)
          )
        ),
        '_',
        '.'
      ) AS position_name_splitter,
      CASE
        WHEN CHARINDEX(
          '_',
          pn.position_name_c
        ) = 0 THEN NULL
        WHEN LEN(
          RIGHT(
            pn.position_name_c,
            CHARINDEX(
              '_',
              REVERSE(pn.position_name_c)
            ) - 1
          )
        ) > 3 THEN NULL
        ELSE LEN(
          RIGHT(
            pn.position_name_c,
            CHARINDEX(
              '_',
              REVERSE(pn.position_name_c)
            ) - 1
          )
        )
      END AS position_count
    FROM
      gabby.recruiting.job_position_c AS pn
    WHERE
      pn.city_c IN (
        'Newark',
        'Camden',
        'Newark & Camden',
        'Miami'
      )
  ) AS p
