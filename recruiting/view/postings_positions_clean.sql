USE gabby GO
CREATE OR ALTER VIEW
  recruiting.postings_positions_clean AS
WITH
  position_setup AS (
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
      LEN(pn.position_name_c) - LEN(REPLACE(pn.position_name_c, '_', '')) AS n,
      REPLACE(
        LEFT(
          pn.position_name_c,
          LEN(pn.position_name_c) - CHARINDEX('_', REVERSE(pn.position_name_c))
        ),
        '_',
        '.'
      ) AS position_name_splitter,
      CASE
        WHEN CHARINDEX('_', pn.position_name_c) = 0 THEN NULL
        WHEN LEN(
          RIGHT(
            pn.position_name_c,
            CHARINDEX('_', REVERSE(pn.position_name_c)) - 1
          )
        ) > 3 THEN NULL
        ELSE LEN(
          RIGHT(
            pn.position_name_c,
            CHARINDEX('_', REVERSE(pn.position_name_c)) - 1
          )
        )
      END AS position_count,
      pg.name AS position_job_posting
    FROM
      gabby.recruiting.job_position_c pn
      LEFT JOIN gabby.recruiting.job_posting_c pg ON pn.job_posting_c = pg.id
    WHERE
      pn.city_c IN ('Newark', 'Camden', 'Newark & Camden', 'Miami')
  ),
  positions_clean AS (
    SELECT
      p.position_number,
      p.position_name,
      p.city AS position_city,
      p.job_type AS position_type,
      p.sub_type AS position_sub_type,
      p.status AS position_status,
      p.new_or_replacement,
      p.region AS position_region,
      p.desired_start_date AS position_start_date,
      p.created_date AS position_created,
      p.date_filled AS position_filled,
      p.position_count,
      CASE
        WHEN p.n = 4 THEN PARSENAME(p.position_name_splitter, 4)
        ELSE 'Invalid position_name Format'
      END AS position_recruiter,
      CASE
        WHEN p.n = 4 THEN PARSENAME(p.position_name_splitter, 3)
        ELSE 'Invalid position_name Format'
      END AS position_location,
      CASE
        WHEN p.n = 4 THEN PARSENAME(p.position_name_splitter, 2)
        ELSE 'Invalid position_name Format'
      END AS position_role_short,
      CASE
        WHEN p.n = 4 THEN PARSENAME(p.position_name_splitter, 1)
        ELSE 'Invalid position_name Format'
      END AS position_recruiting_year,
      p.position_job_posting
    FROM
      position_setup p
  ),
  postings_clean AS (
    SELECT
      pg.name AS job_posting_name,
      pg.created_date AS posting_created_date,
      pg.city_c AS posting_city,
      pg.subject_area_c AS posting_subject,
      pg.grade_c AS posting_grade,
      pg.grade_level_c AS posting_grade_level,
      pg.job_type_c AS posting_type,
      pg.job_sub_type_c AS posting_sub_type,
      pg.full_time_part_time_c AS full_or_part_time,
      pg.status_c AS posting_status,
      pg.publish_start_date_c AS posting_publish_start,
      pg.publish_end_date_c AS posting_publish_end,
      pg.start_date_c AS posting_start
    FROM
      gabby.recruiting.job_posting_c pg
    WHERE
      city_c IN ('Camden', 'Newark', 'Newark & Camden', 'Miami')
  )
SELECT
  pg.job_posting_name,
  pg.posting_created_date,
  pg.posting_city,
  pg.posting_subject,
  pg.posting_grade,
  pg.posting_grade_level,
  pg.posting_type,
  pg.posting_sub_type,
  pg.full_or_part_time,
  pg.posting_status,
  pg.posting_publish_start,
  pg.posting_publish_end,
  pg.posting_start,
  pn.position_number,
  pn.position_name,
  pn.position_city,
  pn.position_type,
  pn.position_sub_type,
  pn.new_or_replacement,
  pn.position_status,
  pn.position_region,
  pn.position_start_date,
  pn.position_created,
  pn.position_filled,
  pn.position_count,
  pn.position_recruiter,
  pn.position_location,
  pn.position_role_short,
  pn.position_recruiting_year
FROM
  postings_clean pg
  LEFT JOIN positions_clean pn ON pg.job_posting_name = pn.position_job_posting
