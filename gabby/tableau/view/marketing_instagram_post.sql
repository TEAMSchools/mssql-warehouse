CREATE OR ALTER VIEW
  tableau.marketing_instagram_post AS
WITH
  history AS (
    -- History w/ recent row
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY
          id
        ORDER BY
          _fivetran_synced DESC
      ) AS row_recent
    FROM
      kipptaf.instagram_business.media_history
    WHERE
      carousel_album_id IS NULL
  ),
  insight AS (
    -- Insights, with row recent
    -- trunk-ignore(sqlfluff/AM04)
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY
          id
        ORDER BY
          _fivetran_synced DESC
      ) AS row_recent
    FROM
      kipptaf.instagram_business.media_insights
  )
SELECT
  h.id AS id_history,
  i.id AS id_insights,
  h.username,
  CASE
    WHEN h.username = 'kippnj' THEN '17841401733578100'
    WHEN h.username = 'kippmiami' THEN '17841407132914300'
  END AS [IG_Account_ID],
  h.created_time,
  h.permalink,
  h.is_story,
  h.media_type,
  h.media_product_type,
  -- ,CAST(h.caption AS TEXT) AS caption
  NULL AS caption,
  i.like_count + i.comment_count AS total_like_comments,
  i.*
FROM
  history AS h
  LEFT OUTER JOIN insight AS i ON h.id = i.id
WHERE
  h.row_recent = 1
  AND i.row_recent = 1
