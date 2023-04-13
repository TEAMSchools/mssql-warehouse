CREATE OR ALTER VIEW tableau.marketing_instagram_page AS 
WITH user_history AS (
    SELECT
        id,
        followers_count,
        media_count,
        _fivetran_synced_date,
        LAG(
            _fivetran_synced_date, 1, '2010-10-06'
        ) OVER(
            PARTITION BY id
            ORDER BY
                _fivetran_synced_date ASC
        ) AS _fivetran_synced_date_prev
    FROM
        (
            SELECT
                id,
                followers_count,
                media_count,
                CAST(_fivetran_synced AS DATE) AS _fivetran_synced_date,
                ROW_NUMBER() OVER(
                    PARTITION BY id,
                    CAST(_fivetran_synced AS DATE)
                    ORDER BY
                        _fivetran_synced DESC
                ) AS rn
            FROM
                kipptaf.instagram_business.user_history
        ) sub
    WHERE
        rn = 1
) --profile visits by date, daily reach, 28 day reach
SELECT
    ui.id,
    ui.[date],
    ui.profile_views,
    ui.reach,
    ui.reach_28_d,
    uh.followers_count,
    uh.media_count
FROM
    kipptaf.instagram_business.user_insights ui
    LEFT JOIN user_history uh ON ui.id = uh.id
    AND ui.[date] >= uh._fivetran_synced_date_prev
    AND ui.[date] < uh._fivetran_synced_date
ORDER BY
    ui.[date]
