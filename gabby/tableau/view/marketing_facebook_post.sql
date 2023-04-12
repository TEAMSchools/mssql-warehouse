CREATE OR ALTER VIEW tableau.marketing_facebook_post AS
SELECT
	ph.id,
	CAST(ph.updated_time AS DATE) AS updated_date,
	CAST (ph.created_time AS DATE) AS created_date,
	ph.page_id,
	ph.status_type,
	 --post lifetime metrics
    MAX(pm.post_impressions) AS post_impressions,
	MAX(pm.post_impressions_paid) AS post_impressions_paid,
	MAX(pm.post_impressions_organic) AS post_impressions_organic,
	MAX(pm.post_impressions_nonviral) AS post_impressions_nonviral,
	MAX(pm.post_impressions_viral) AS post_impressions_viral,
	MAX(pm.post_clicks) AS post_clicks,
    MAX(pm.post_reactions_like_total) 
     + MAX(pm.post_reactions_love_total) 
     + MAX(pm.post_reactions_wow_total) 
     + MAX(pm.post_reactions_haha_total) 
     + MAX(pm.post_reactions_sorry_total)
	 + MAX(pm.post_reactions_anger_total)
     AS total_post_engagement,
	ph._fivetran_synced,
    ROW_NUMBER() OVER (
       PARTITION BY ph.id
         ORDER BY ph.updated_time DESC) AS row_recent
FROM kipptaf.facebook_pages.post_history AS ph
JOIN kipptaf.facebook_pages.lifetime_post_metrics_total AS pm
  ON (ph.id = pm.post_id)

--WHERE ph.page_id != '11676778731' 

GROUP BY  
     ph.id,
	ph.updated_time,
	ph.created_time,
	ph.page_id,
	ph.status_type,
	ph._fivetran_synced
